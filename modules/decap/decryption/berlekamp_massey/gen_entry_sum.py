'''
 * Code generation file: generates the entry_sum module.
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
 
parser.add_argument('-N', dest='N', type=int, default=20,  
          help='size of the vector') 
 
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
 
args = parser.parse_args()
 
m = args.m
N = args.N

print("""
// module for adding up entries in a vector

module entry_sum (
  input wire clk,
  input wire [{0}:0] vector,
  output wire [{1}:0] sum
);
""".format(m*N-1, m-1))

sum = ""
for i in range(N):
  if (i < (N-1)):
    sum += "vector[{0}:{1}] ^ ".format(i*m+m-1, i*m)
  else:
    sum += "vector[{0}:{1}]".format(i*m+m-1, i*m)

print("  assign sum = {0};".format(sum))

print("\nendmodule\n")
