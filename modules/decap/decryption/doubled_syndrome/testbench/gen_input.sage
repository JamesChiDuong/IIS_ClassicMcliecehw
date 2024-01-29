#!/usr/bin/sage

#
# This file is part of the testbench, which generates random inputs.
# 
# Copyright (C) 2018
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
 
parser.add_argument('-t', dest='t', type=int, default=119,  
          help='number of errors; default = 119')
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
parser.add_argument('-w', dest='w', type=int, default=0,
          help='weight of ciphertext c, ranges in [0, m*t]')      
parser.add_argument('-s', '--seed', dest='seed', type=str, default="random",
          help='seed')
args = parser.parse_args()

t = args.t
m = args.m
w = args.w

if args.seed != "random":
  sys.stderr.write("WARING: using fixed seed {0}!\n".format(args.seed))
  set_random_seed(str(args.seed))
 
fmt = "{0:0" + str(m) + "b}"

F.<x> = GF(2)[]
K.<a> = GF(2^m, modulus="first_lexicographic")
 
def random_irred(K, t):
  Kx.<x> = K[]

  # get irreducible polynomial
  g = PolynomialRing(GF(2), 'x').irreducible_element(t, algorithm="first_lexicographic")
  
  Kg = K.extension(g)
  
  iden_matrix = matrix(K, t, t)
  for i in range(t):
      iden_matrix[i, i] = 1
  
  while True:
    r = Kg.random_element()
    coeff = matrix(K, t, t + 1)
  
    ri = Kg.one()
    
    for i in range(t + 1):
        for j in range(t):
            coeff[j, i] = ri[j]
        ri *= r
    
    coeff_gs = coeff.echelon_form()
    coeff_gs_sq = coeff_gs[:, :t]

    r_min_poly = x^t
    for i in range(t):
        r_min_poly += coeff_gs[i, t]*x^i

    return r_min_poly

g = random_irred(K, t)

f = open("poly_g.in", "w")

for i in reversed(range(t+1)):
  f.write(fmt.format(g[i].integer_representation())) 
f.write('\n')

f.close()

if args.seed:
  random.seed(args.seed)

# generate a random binary string as ciphertext c
cipher = []
for i in range(m*t):
  if i < w:
    cipher.append(1)
  else:
    cipher.append(0)

random.shuffle(cipher)

f = open("cipher.in", "w")

for i in range(m*t):
  f.write(str(cipher[i]))
f.write('\n')

f.close()



