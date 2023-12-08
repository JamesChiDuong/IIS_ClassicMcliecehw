'''
 * Function: generate input data.
 *
 * Copyright (C) 2018
 * Authors: Wen Wang <wen.wang.ww349@yale.edu>
 *          Ruben Niederhagen <ruben@polycephaly.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
'''
import argparse
import random
import sys

parser = argparse.ArgumentParser(description='Generate sort input data.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--list-len', dest='n', type=int, required=True,
          help='length of list')
parser.add_argument('-m', '--index', dest='m', type=int, required=True, default=13,
          help='bit width of index (finite field size)')
parser.add_argument('-b', '--sigma2', dest='b', type=int, required=True, default=13,
          help='bit width of random numbers (sigma2)')
parser.add_argument('-s', '--seed', dest='seed', type=int, required=False, default=None,
          help='seed')
args = parser.parse_args()

n = args.n
m = args.m
b = args.b

b_format_str = "{0:0" + str(args.b) + "b}"
m_format_str = "{0:0" + str(args.m) + "b}"

if args.seed:
  random.seed(args.seed)
  
rand_list = []
while len(rand_list) < n:
  rand_int = random.randint(0, 2**b-1)
  if rand_int not in rand_list:
    rand_list.append(rand_int)

for i in range(n):
  sys.stdout.write(b_format_str.format(rand_list[i]))
  sys.stdout.write(m_format_str.format(i))
  sys.stdout.write("\n")
  
  
