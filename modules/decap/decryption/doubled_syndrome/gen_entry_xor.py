'''
 * This file generates entry_xor module.
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

import sys

import argparse

parser = argparse.ArgumentParser(description='Generate memory contents for H.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
 
parser.add_argument('-n', dest='n', type=int, default=8192,  
          help='length of the vector') 
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
args = parser.parse_args()
n = args.n
m = args.m

print("""
// entrywise xor

module entry_xor (
  input wire [{0}:0] vector,  
  output wire [{1}:0] res
);
""".format(m*n-1, m-1))

res_str = ""
for j in range(n):
  if (j != (n-1)):
    res_str += "vector[{0}:{1}] ^ ".format(m*j+m-1, m*j)
  else:
    res_str += "vector[{0}:{1}];\n".format(m*j+m-1, m*j)
print("assign res = {0}".format(res_str))

print("\nendmodule")
