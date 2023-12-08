#
# Function: generate theoretical results.
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

import argparse, sys

parser = argparse.ArgumentParser(description='Generate result of rad_conv_twisted.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required=True,
          help='number of coeffs')
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
parser.add_argument('in_coeff', metavar='in_coeff', type=str,
                    help='input file containing coefficients')
parser.add_argument('-w', '--mem_width', dest='w', type=int, required=True, default=0,
          help='number of multipliers')                   
args = parser.parse_args()

num = args.n
gf = args.m
w = args.w

mul_pow = int(math.ceil(math.log(w, 2)))  

assert (int(math.pow(2, mul_pow)) == w), "number of multipliers used in reduction should be a power of 2!"

factor = mul_pow-(gf-int(math.ceil(math.log(num, 2)))-1)
 
num_power = int(math.log(num, 2))
mem_width = int(math.pow(2, (gf-num_power)))//2

K.<a> = GF(2^gf, modulus="first_lexicographic")
Kx.<x> = K[]

# reconstruct the input polynomial
with open(args.in_coeff, "r") as f:
  coeff_in = f.readline().strip()

coeff = []

while coeff_in != "":
  coeff.append(K.fetch_int(int(coeff_in[:gf],2)))
  coeff_in = coeff_in[gf:]

g = Kx.zero()

for i,v in enumerate(reversed(coeff)):
  g += x^i * v

#print(g)

basis = [a^i for i in reversed(range(gf))]

def convert(beta, num):

	ret = 0
	for i in range(len(beta)):
		if (num >> i) % 2:
			ret += beta[i]

	return ret

L = []

for j in range(2^gf):
	L.append(K(convert(basis, j)))

for i in range(num//int(math.pow(2, factor))):
    for j in range(2*mem_width*int(math.pow(2, factor))):
        num = 2*mem_width*int(math.pow(2, factor))*(i+1)-1- j
        x = L[num]
        print("{0:0{gf}b}".format(g(x).integer_representation(), gf=gf), end='')
        sys.stdout.softspace = 0
    print('\n')

