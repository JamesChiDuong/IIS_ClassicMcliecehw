#
# Function: generate theoretical output.
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

# generate theoretical result for twisted radix conversion result

import argparse, sys
from collections import defaultdict

parser = argparse.ArgumentParser(description='Generate result of rad_conv_twisted.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required=True,
          help='number of coeffs')
parser.add_argument('-m', '--gf', dest='gf', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
parser.add_argument('in_coeff', metavar='in_coeff', type=str,
                    help='input file containing coefficients')
                    
args = parser.parse_args()

num = args.n
gf = args.gf
twist_count = int(math.log(num, 2))-1

F2.<x> = GF(2)[]

K.<a> = GF(2^gf, modulus="first_lexicographic")
Kx.<x> = K[]

# reconstruct the input polynomial
with open(args.in_coeff, "r") as f:
  coeff_in = f.readline().strip()

coeff = []

while coeff_in != "":
  coeff.append(Kx(K.fetch_int(int(coeff_in[:gf], 2))))
  coeff_in = coeff_in[gf:]

# reconstruct the polynomial g(x)
g = Kx.zero()

for i, v in enumerate(reversed(coeff)):
   g += x^i*v


def radix_conv(f, m=None):
  Kx = parent(f)
  x = Kx.gens()[0]

  if m == None:
    m = ceil(log(f.degree()+1, 2))

  if m <= 1:
    return Kx(f[0]), Kx(f[1])

  n = 2^(m-2)

  Q, R = f.quo_rem(x^(2*n) - x^n)

  Q0, Q1 = radix_conv(Q, m-1)
  R0, R1 = radix_conv(R, m-1)

  return R0 + x^n*Q0, R1 + x^n*Q1


def radix_conv_twisted(r, m, base = None):
  x = parent(r).gens()[0]
  a = r.base_ring().gens()[0]

  if not base:
    base = [a^i for i in range(m)]

  if r.degree() <= 0:
    # the constant term for any input
    return [r[0]]

  cb = base[0]

  r = r(cb * x)

  base = [b/cb for b in base]

  base = base[1:]

  # transform r = r0(x^2 - x) + x*r1(x^2 - x)
  r0, r1 = radix_conv(r)

  assert r - (r0(x^2 - x) + x*r1(x^2 - x)) == 0
  
  n_base = [b^2 - b for b in base]

  r0_ev = radix_conv_twisted(r0, m, n_base)
  r1_ev = radix_conv_twisted(r1, m, n_base)

  # add remaining part in case len(r1_ev) < len(r0_ev)
  while len(r1_ev) < len(r0_ev):
     r1_ev = [K.zero()] + r1_ev

  # interleve r0_ev = [e00, e01, e02, ...] and r1_ev = [e10, e11, e12, ...]
  # as [e10, e00, e11, e01, e12, e02, ...]
  return [val for pair in zip(r1_ev, r0_ev) for val in pair]

res = radix_conv_twisted(g, gf)

for i in range(num - len(res)):
  res = [K.zero()] + res

for i in range(len(res)-num, len(res)):
  sys.stdout.write(("{0:0%db}" % gf).format(res[i].integer_representation()))
           
sys.stdout.write("\n")              

