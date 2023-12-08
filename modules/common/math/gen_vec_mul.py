'''
 * Function: generate vector multiplication module.
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

#! /usr/bin/env python3

# Function: code generation tool for module vec_mul.v
 
import argparse

parser = argparse.ArgumentParser(description='Generate vec_mul module.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required= True,
          help='number of coeffs')
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
parser.add_argument('--name', dest='name', type=str, required=True, default=None,
          help = 'name for generated module')

args = parser.parse_args()

num = args.n
gf = args.m
name = args.name

if not name:
  name = "vec_mul_{0}".format(num)

print("//vector multiplicaiton on GF(2^gf)")
print("""module {1} (
 
  input  wire	 		 clk,
  input  wire [{0}:0]    vec_a,
  input  wire [{0}:0]	 vec_b ,
  output wire  [{0}:0]    vec_c
   
);
""".format(gf*num-1, name))

print("""wire [{0}:0] A;
wire [{0}:0] B;
wire [{0}:0] C;
""".format(gf*num-1))
 

for i in range(num):
  print("assign A[{0}:{1}] = vec_a[{0}:{1}];".format(gf*i+gf-1, gf*i))

print("")

for i in range(num):
  print("assign B[{0}:{1}] = vec_b[{0}:{1}];".format(gf*i+gf-1, gf*i))

print("")  

for i in range(num):
  print("assign vec_c[{0}:{1}] = C[{0}:{1}];".format(gf*i+gf-1, gf*i)) 

print("")

for i in range(num):
  print("""gf_mul gf_mul_inst{0} (
  .clk(clk),
  .dinA(A[{1}:{2}]),
  .dinB(B[{1}:{2}]),
  .dout(C[{1}:{2}])
);
""".format(i, gf*i+gf-1, gf*i))

print("endmodule")
print("")
