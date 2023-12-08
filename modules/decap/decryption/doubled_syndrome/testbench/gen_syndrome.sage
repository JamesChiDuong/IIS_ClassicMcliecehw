#
# Copyright (C) 2018
# Authors: Wen Wang <wen.wang.ww349@yale.edu>
#          Ruben Niederhagen <ruben@polycephaly.org>
# Function: generate a random syndrome.
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

parser = argparse.ArgumentParser(description='Generate memory contents for H.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
 
parser.add_argument('-t', dest='t', type=int, default=119,  
          help='number of errors; default = 119')
 
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
         
parser.add_argument('in_coeff', metavar='in_coeff', type=str,
                    help='input file containing coefficients') 
                    
parser.add_argument('in_cipher', metavar='in_cipher', type=str,
                    help='input file containing ciphertext') 
                    
parser.add_argument('in_P', metavar='in_P', type=str,
                    help='input file containing permuted indices')
 
args = parser.parse_args()

t = args.t
m = args.m

L = m*t
K = 2^m

F.<x> = GF(2)[]
KK.<a> = GF(2^m, modulus="first_lexicographic")
Kx.<x> = KK[]
 
fmt = "{0:0" + str(m) + "b}"

# reconstruct ciphertext c
with open(args.in_cipher, "r") as f:
  cipher = f.readline().strip()

cipher_list = []

while cipher != "":
  cipher_list.append(KK(int(cipher[:1])))
  cipher = cipher[1:]

cipher_vec = matrix(KK, L, 1)

for i in range(L):
  cipher_vec[i, 0] = cipher_list[i]
    
f.close()

# reconstruct Goppa polynomial g(x)
with open(args.in_coeff, "r") as f:
  coeff_in = f.readline().strip()

coeff = []

while coeff_in != "":
  coeff.append(Kx(KK.fetch_int(int(coeff_in[:m], 2))))
  coeff_in = coeff_in[m:]

g = Kx.zero()

for i, v in enumerate(reversed(coeff)):
  g += x^i*v
  
#print(g)

f.close()

# reconstruct permutation indices
P_list = []

with open(args.in_P, "r") as f:
  for line in f:
    if not line.startswith("//"):
      if not (line == "\n"):
        P_list.append(int(line[:m], 2))
        
f.close()

P_trans = matrix(KK, K, K)
 
for i in range(K):
  row = P_list[i]
  P_trans[row, i] = 1
  
# polynomial evaluation
basis = [a^i for i in reversed(range(m))]

def convert(beta, num):
  ret = 0
  for i in range(len(beta)):
    if (num >> i) % 2:
      ret += beta[i]
  return ret

alpha = []

for j in range(2^m):
  alpha.append(KK(convert(basis, j)))

eva = []

for i in range(2^m):
  x = alpha[i]
  eva.append(g(x)) 
  if (g(x) == KK.zero()):
    print(f'ERROR! {i} {x}')
    
Y = matrix(KK, 2*t, K)
for i in range(K):
  Y[0, i] = KK.one()
  for j in range(1, 2*t):
    Y[j, i] = Y[j-1, i]*alpha[i]

Z = matrix(KK, K, K)
for i in range(K):
  Z[i, i] = (eva[i])^-2

H_2_P = Y*Z*P_trans 

S = H_2_P[:, :L]*cipher_vec

for i in range(2*t):
  bin = fmt.format((S[i, 0]).integer_representation())
  sys.stdout.write(bin)
  sys.stdout.write("\n")
 


  
