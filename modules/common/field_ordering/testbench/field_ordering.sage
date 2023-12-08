# This file is the testbench for the gen_support module.
# 
# Copyright (C) 2018
# Authors: Wen Wang <wen.wang.ww349@yale.edu>
#          Ruben Niederhagen <ruben@polycephaly.org>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

import argparse


parser = argparse.ArgumentParser(description='Generate random permutation P.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')

parser.add_argument('-s', '--sigma2', dest='sigma2', type=int, default=32,
          help='number of bits from PRNG to be compared')

args = parser.parse_args()

m = args.m

q = 2^m
sigma2 = args.sigma2

F2 = GF(2)
F2z.<z> = F2[]

Fq.<zinFq> = GF(q,name='zinFq')

def is_fieldordering(alpha):
  if len(alpha) != q: return False
  if len(set(alpha)) != q: return False
  return all(parent(alphaj) == Fq for alphaj in alpha)


def is_bit_vector(e,n):
  if len(e) != n: return False
  return all(parent(ei) == F2 for ei in e)

def FieldOrdering(b):
  assert is_bit_vector(b,sigma2*q)
  a = [sum(ZZ(b[sigma2*j+i])*2^i for i in range(sigma2)) for j in range(q)]
  assert all(parent(ai) == ZZ for ai in a)
  assert all(ai >= 0 for ai in a)
  assert all(ai < 2^sigma2 for ai in a)

  if len(set(a)) < q: return False

  a = [(a[i],i) for i in range(q)]
  a.sort()

  for i in range(q-1):
    assert a[i][0] < a[i+1][0]

  alpha = []
  for i in range(q):
    alpha += [sum((1&(a[i][1]>>j))*zinFq^(m-1-j) for j in range(m))]

  assert is_fieldordering(alpha)
  return alpha


b = [F2.random_element() for i in range(sigma2*q)]

alpha = FieldOrdering(b)


b = [b[i:i + sigma2] for i in range(0, len(b), sigma2)]

# Need to reverse bit order!
b_out = "\n".join(["".join(str(i) for i in v)[::-1] for v in b])

#print(b_out)

f = open("sage_rand.out", "w")
f.write(b_out)
f.write("\n")
f.close()

fmt_str = "{0:0" + str(m) + "b}"

# Need to reverse bit order!
alpha_out = "\n".join([fmt_str.format(v.integer_representation())[::-1] for v in alpha])

#print(alpha_out)

f = open("sage_perm.out", "w")
f.write(alpha_out)
f.write("\n")
f.close()

