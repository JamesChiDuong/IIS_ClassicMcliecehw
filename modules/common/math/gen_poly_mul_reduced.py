'''
 * Function: This file generates the poly_mul_reduced module.
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

# Function: code generation tool for polynomial multiplication(after reduced) module:
# mul & red
 
import argparse

parser = argparse.ArgumentParser(description='Generate poly_mul_reduced module.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required= True,
          help='number of coeffs of the polynomial')
parser.add_argument('-t', '--poly_deg', dest='t', type=int, required= True,
          help='degree of reduction polynomial')
parser.add_argument('-m','--gf', dest='gf', type=int, required= True, default=13,
          help='field 2^m')
args = parser.parse_args()

num = args.n
gf = args.gf
t = args.t

print("//polynomial multiplication on two degree-{0} polynomials".format(t-1))

print("")

print("""module poly_mul_reduced (
  input  wire		        start,
  input  wire 		      clk,
  input  wire [{0}:0]  poly_g,
  input  wire [{0}:0]  poly_f,
  output wire [{0}:0]  poly_out,
  output wire 		      done
//  output wire          poly_mul_20_done
);""".format(gf*t-1))

 
print("""
wire [{0}:0] poly_R;
wire          poly_mul_done;
""".format(gf*(2*num-1)-1))

print("""poly_mul_koa poly_mul_koa_inst (
  .clk(clk),
  .start(start),
  .poly_g({{{0}'b0, poly_g}}),
  .poly_f({{{0}'b0, poly_f}}),
  .poly_out(poly_R),
  .done(poly_mul_done)
);

poly_red koa_red_inst (
  .clk(clk),
  .start(poly_mul_done),
  .poly_in(poly_R[{1}:0]),
  .poly_out(poly_out),
  .done(done)
);

endmodule
""".format(gf*(num-t), gf*(2*t-1)-1, t))

