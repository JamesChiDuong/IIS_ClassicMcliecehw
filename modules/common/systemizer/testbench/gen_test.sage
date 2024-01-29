#!/usr/bin/sage

#
# This file is part of the testbench, which generates a random input matrix file.
# 
# Copyright (C) 2016
# Authors: Wen Wang <wen.wang.ww349@yale.edu>
#          Ruben Niederhagen <ruben@polycephaly.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import sys
import random
import argparse

parser = argparse.ArgumentParser(description='Generate input matrix.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-N', dest='N', type=int, required= True,
          help='block size')
parser.add_argument('-L', dest='L', type=int, required= True,
          help='number of rows')
parser.add_argument('-K', dest='K', type=int, required= True,
          help='number of columns; must be multiple of N')
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
parser.add_argument('-s', '--seed', dest='seed', type=str, default="random",
          help='seed')
parser.add_argument('--systemizable', dest='systemizable', action='store_true')
parser.add_argument('--not-systemizable', dest='systemizable', action='store_false')
parser.set_defaults(systemizable=None)
args = parser.parse_args()


N = args.N
L = args.L
K = args.K
m = args.m

K = K - (K % N)

if args.seed != "random":
  sys.stderr.write("WARING: using fixed seed {0}!\n".format(args.seed))
  set_random_seed(int(args.seed))
else:
  seed = random.randint(0, sys.maxsize)
  set_random_seed(seed)
  sys.stderr.write("seed: {0}\n".format(seed))

MS = MatrixSpace(GF(2^m), L, K)

run = True

while run:
  M = MS.random_element()

#  while M[0,0] == 0:
#    M[0,0] = GF(2^m).random_element()

  run = False

  if args.systemizable == True:
    E = M.echelon_form()
  
    for i in range(len(E.rows())):
      if E[i,i] == 0:
         run = True

  if args.systemizable == False:
    num = 0

    E = M.echelon_form()
  
    for i in range(len(E.rows())):
      if E[i,i] == 1:
         num += 1

    run = (num==L)


fmt = "{0:0" + str(m) + "b}"

for s in range(0, len(M[0]), N):
  for r in M.rows():
    for i in reversed(r[s:s+N]):
      if m > 1:
        sys.stdout.write(fmt.format(i.integer_representation()))
      else:
        sys.stdout.write("{0}".format(i))
  
    sys.stdout.write("\n")

