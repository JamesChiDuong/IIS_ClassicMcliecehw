#
# Function: generate a random polynomial for testing.
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
import argparse

parser = argparse.ArgumentParser(description='Generate input polynomials.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-t', '--poly_deg', dest='t', type=int, required= True,
          help='degree of the polynomial')
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
parser.add_argument('-s', '--seed', dest='seed', type=int, required=False, default=None,
          help='seed')

args = parser.parse_args()

t = args.t

if args.seed:
  set_random_seed(args.seed)

m = args.m
 
K.<a> = GF(2^m)
Kx.<x> = K[]

set_random_seed(1)

g = Kx.random_element(t-1)
f = Kx.random_element(t-1)

for i in range(t):
  bin_coeff = ("{0:0"+str(m)+"b}").format(g[t-1-i].integer_representation())
  sys.stdout.write(bin_coeff)

sys.stdout.write("\n")

for i in range(t):
  bin_coeff = ("{0:0"+str(m)+"b}").format(f[t-1-i].integer_representation())
  sys.stdout.write(bin_coeff)

sys.stdout.write("\n")

