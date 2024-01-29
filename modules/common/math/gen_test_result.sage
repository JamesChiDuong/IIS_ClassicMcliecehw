#
# Function: compute the theoretical output.
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

import argparse
import math

parser = argparse.ArgumentParser(description='generate result for polynomial multiplication.',
								formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-t', '--poly_deg', dest='t', type=int, required=True,
				   help='degree of the polynomial')
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
 
 
args = parser.parse_args()

t = args.t
m = args.m
 
n = 2^m

K.<a> = GF(2^m,  modulus="first_lexicographic")
Kx.<x> = K[]

coeff = []

for line in sys.stdin:
  coeff.append(line)

g = coeff[0]
f = coeff[1]

coeff_g = []
coeff_f = []

while g != "\n":
  coeff_g.append(K.fetch_int(int(g[:m],2)))
  g = g[m:]

while f != "\n":
  coeff_f.append(K.fetch_int(int(f[:m],2)))
  f = f[m:]

poly_g = Kx.zero()
poly_f = Kx.zero()

for i,v in enumerate(reversed(coeff_g)):
  poly_g += x^i*v

for i,v in enumerate(reversed(coeff_f)):
  poly_f += x^i*v
 
poly = poly_g*poly_f
red = PolynomialRing(GF(2), 'x').irreducible_element(t, algorithm="first_lexicographic")

poly = poly.mod(red)

for i in range(poly.degree()+1):
    a = ("{0:0" + str(m) + "b}").format(poly[poly.degree()-i].integer_representation())
    sys.stdout.write(a)

sys.stdout.write("\n")

