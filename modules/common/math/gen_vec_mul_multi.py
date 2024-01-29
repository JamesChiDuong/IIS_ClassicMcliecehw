'''
 * Function: generate vector multiplication module.
 * This file is the testbench for the rad_conv+twist module.
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

# Function: code generation tool for module vec_mul_multi.v, which trades number of cycles for number of multipliers

import argparse
import math
import sys

parser = argparse.ArgumentParser(description='Generate vec_mul_multi module.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-n', '--num', dest='n', type=int, required=True,
          help='number of coeffs')
parser.add_argument('-s', '--sec', dest='sec', type=int, required=True,
          help='number of multipliers')
parser.add_argument('-m', '--gf', dest='gf', type=int, required=True,
          help='finite field (GF(2^m))')
parser.add_argument('--name', dest='name', type=str, required=True, default="vec_mul_multi",
          help='name of the module')
parser.add_argument('--name_sub', dest='name_sub', type=str, required=True, default="vec_mul",
          help='name of the submodule')
parser.add_argument('-u', '--usage', dest='usage', type=str, default=None,
          help="Deprecated! Use '--name' instead!")
args = parser.parse_args()

if args.usage:
  args.name = "vec_mul_multi_" + args.usage
  sys.stderr.write("\n\nWARNING! Parameter '-u' ('--usage') deprecated! Use '--name' instead!\n\n\n")

num = args.n
mul = args.sec
gf = args.gf

assert (mul < num), "\n\n ERROR! \n Reason: \n    Number of multipliers should be smaller than the number of coefficients. \n    Otherwise, use plain vector multiplier instead!\n"

#print("""module vec_mul_multi_{1} (
print("""module {1} (

  input  wire clk,
  input  wire start,
  input  wire [{0}:0] vec_a,
  input  wire [{0}:0] vec_b,
  output wire [{0}:0] vec_c,
  output wire done
);""".format(gf*num-1, args.name))

print("""
reg start_buffer = 1'b0;

reg running = 1'b0;

reg [{0}:0] counter = {2}'b0;

always @(posedge clk)
  begin
    start_buffer <= start;

    running <= start_buffer ? 1'b1 :
               done ? 1'b0 :
               running;

    counter <= start_buffer ? {2}'b0 :
               (running && (counter <= {2}'d{1})) ? counter + {2}'d1 :
               counter;
  end

assign done = (counter == {1});
""".format(int(math.log(int(num/mul), 2)), int(num/mul)-1, int(math.log(int(num/mul), 2))+1))

# use shifting to get A and B
print("""
reg [{0}:0] vec_a_reg = {2}'b0;
reg [{0}:0] vec_b_reg = {2}'b0;

always @(posedge clk)
  begin
    vec_a_reg <= start ? vec_a : (vec_a_reg >> {1});
    vec_b_reg <= start ? vec_b : (vec_b_reg >> {1});
  end
""".format(gf*num-1, gf*mul, gf*num))

print("""
wire [{0}:0] A;
wire [{0}:0] B;
wire [{0}:0] C;

assign A = vec_a_reg[{0}:0];
assign B = vec_b_reg[{0}:0];
""".format(mul*gf-1))

print("""reg [{0}:0] vec_c_buffer = 0;

always @(posedge clk)
  begin
    vec_c_buffer <= start_buffer ? {{C, {2}'b0}} :
                    (running && !done) ? {{C, vec_c_buffer[{3}:{4}]}} :
                    vec_c_buffer;
  end
 
assign vec_c = vec_c_buffer;""".format(gf*num-1, gf*mul, gf*(num-mul), gf*num-1, gf*mul))

print("""
{0} {0}_inst (
  .clk(clk),
  .vec_a(A),
  .vec_b(B),
  .vec_c(C)
);
""".format(args.name_sub))

print("endmodule")
print("")
