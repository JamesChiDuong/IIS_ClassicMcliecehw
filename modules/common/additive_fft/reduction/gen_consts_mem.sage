#
# Function: generate consts values for reduction.
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
import math

f = sys.stdout

import argparse 
import math

parser = argparse.ArgumentParser(description='Generate reduction module: polynomial evaluation part.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required=True,
          help='number of coeffs')
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
parser.add_argument('-w', '--mem_width', dest='w', type=int, required=True, default=0,
          help='number of multipliers')
 
args = parser.parse_args()

num = args.n
gf = args.m
w = args.w

mul_pow = int(math.ceil(math.log(w, 2)))  

assert (int(math.pow(2, mul_pow)) == w), "number of multipliers used in reduction should be a power of 2!"

factor = mul_pow-(gf-int(math.ceil(math.log(num, 2)))-1)


num_power = int(math.log(num, 2)) # 128 = 2^7
mem_width = int(math.pow(2, (gf-num_power+factor)))//2
single_width = int(math.pow(2, (gf-num_power)))
 
F2.<x> = GF(2)[]

F.<a> = GF(2^gf, modulus="first_lexicographic")

basis = [ a^i for i in reversed(range(gf)) ]

def convert(beta, num):

	ret = 0
	for i in range(len(beta)):
		if (num >> i) % 2:
			ret += beta[i]

	return ret
 
L_list = []

for i in range(gf-1, gf-num_power-1, -1):
 
	basis = [ basis[j] / basis[i] for j in range(i)]

	#print(basis)

	L = []

	for j in range(2^i):
		L.append( F(convert(basis, j)).integer_representation() )

	L_list.append(L)

	basis = [ e^2 + e for e in basis ]

	#print('len_L = ', len(L))

#print(L_list[3])

# print(the first "factor" rows, which is special)
for i in range(factor): # within one round
  for x in range(2): # split the constants in half for mem_coeff_A and mem_coeff_B
    for j in range(int(math.pow(2, factor-i-1))): # within each pattern
      for p in range(2): # duplicate the constant values for two rows
        for l in range(int(math.pow(2, i))): # within each block
          for q in range(single_width/2): # within each element
            wrdata = ("{0:0%db}" %gf).format(L_list[num_power-1-i][len(L_list[num_power-1-i])-1-x*len(L_list[num_power-1-i])/int(math.pow(2, i+1))-l*single_width-q])
            sys.stdout.write(wrdata)
  sys.stdout.write('\n')

# the following (num_power-factor) rounds, share the same pattern
 
for i in range(factor, num_power):
  L_len = len(L_list[num_power-1-i])
   
  for k in range(L_len//(2*mem_width)): # one row of consts
    for x in range(2): # consts for mem_coeff_A and mem_coeff_B
      for j in range(int(math.pow(2, factor))): # within one block
        for p in range(single_width//2): # one element
          index = (k+1)*2*mem_width-1-x*L_len//int(math.pow(2, i+1))-j*single_width-p
          wrdata = ("{0:0%db}" %gf).format(L_list[num_power-1-i][index])
          sys.stdout.write(wrdata)
    sys.stdout.write('\n')




