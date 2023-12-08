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

#!/usr/bin/sage

#
# This file is part of the testbench, which generates a random ciphertext for decoding.

import sys
import random
import argparse

parser = argparse.ArgumentParser(description='Generate input matrix.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-t', dest='t', type=int, default=119,
          help='number of errors; default = 119')
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
parser.add_argument('-n', dest='n', type=int, default=6960,
          help='code length')
parser.add_argument('-P', metavar='in_P', type=str,
                    help='input file containing permuted indices')
parser.add_argument('-s', '--seed', dest='seed', type=str, default="random",
          help='seed')
parser.add_argument('--error', type=str,
                    help='output file plaintext', default='error.in')
parser.add_argument('--cipher', type=str,
                    help='output file ciphertext', default='cipher.in')
parser.add_argument('--polyg', type=str,
                    help='output file for polynomial g', default='poly_g.in')
args = parser.parse_args()

t = args.t
m = args.m
n = args.n
L = m*t
num = 2^m

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

f = open(args.polyg, "w")

for i in reversed(range(t+1)):
  f.write(fmt.format(g[i].integer_representation()))
f.write('\n')

f.close()

if args.seed:
  random.seed(args.seed)

# generate a weight-t, length n binary string as error e
error = [1]*t + [0]*(n-t)
shuffle(error)

f = open(args.error, "w")
for i in range(n):
  f.write(str(error[i]))
f.write('\n')

f.close()

# encryption: generate ciphertext
# reconstruct permutation indices
P_list = []

with open(args.P, "r") as f:
  for line in f:
    if not line.startswith("//"):
      if not (line == "\n"):
        P_list.append(int(line[:m], 2))

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
  alpha.append(K(convert(basis, j)))

alpha_permuted = []

for j in range(2^m):
  alpha_permuted.append(alpha[P_list[j]])

eva = []

for i in range(2^m):
  x = alpha[i]
  eva.append(g(x))
  if (g(x) == K.zero()):
    print(f'ERROR! {i} {x}')

Y = matrix(K, t, num)
for i in range(num):
  Y[0, i] = K.one()
  for j in range(1, t):
    Y[j, i] = Y[j-1, i]*alpha[i]

Z = matrix(K, num, num)
for i in range(num):
  Z[i, i] = (eva[i])^-1

P_trans = matrix(K, num, num)

for i in range(num):
  row = P_list[i]
  P_trans[row, i] = 1

H = Y*Z*P_trans

H_2 = matrix(GF(2), L, n)

for i in range(n):
  for j in range(t):
    element = (H[j, i]).integer_representation()
    for k in range(m):
      row_num = m*j+k
      if (element >> k) & 1 == 1:
        H_2[row_num, i] = 1
      else:
        H_2[row_num, i] = 0

iden_matrix = matrix(K, L, L)
for i in range(L):
    iden_matrix[i, i] = 1

H_2 = H_2.echelon_form()
if H_2[:, :L] != iden_matrix:
  print("\nERROR!\nPlease try new seeds.")
else:
  ciphertext = (H_2*vector(error)).list()
  f = open(args.cipher, "w")

  for i in range(m*t):
    f.write(str(ciphertext[i]))
  f.write('\n')

  f.close()

# check re-encryption
def dbl_synd(c, priv): 
  g, alphas, m, n, t = priv

  # extend to length n
  r = c + [0] * (n - len(c))

  # p.11, top: "the inputs r_\alpha are a received word divided by g(\alpha)^2"
  for i in range(n):

    #print(fmt.format(alphas[i].integer_representation()))
    #if (r[i] != 0):
    #  print(i)
    r[i] = K(r[i]) / g(alphas[i])^2

  d = 2*t - 1

  syndrome = []

  for j in range(d+1):
    s = K.zero()
    for i in range(n):
      s += r[i]*alphas[i]^j

    syndrome.append(s)

  return syndrome
 
#syndrome = dbl_synd(ciphertext, (g, alpha_permuted, m, n, t))

syndrome_re_encrypt = dbl_synd(error, (g, alpha_permuted, m, n, t))
 
#print(ciphertext)
#print(syndrome)

#for v in syndrome:
#  print(fmt.format(v.integer_representation()))

#print("\n")
#print(syndrome_re_encrypt)

#for v in syndrome_re_encrypt:
#  print(fmt.format(v.integer_representation()))
 
