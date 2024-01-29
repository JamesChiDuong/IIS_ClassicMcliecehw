'''
 * Function: generate the schoolbook multiplication module.
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

# Function: code generation tool for polynomial multiplication: use n multipliers for n*n multiplications 
 
import argparse

parser = argparse.ArgumentParser(description='Generate poly_mul module.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required= True,
          help='number of coeffs')
parser.add_argument('-m','--gf', dest='gf', type=int, required= True, default=13,
          help='field 2^m')
args = parser.parse_args()

num = args.n
gf = args.gf

print("// {0} gf multipliers used".format(num))

print("")

print("""module poly_mul_sb (
  input  wire          start,
  input  wire	 		     clk,
  input  wire [{0}:0]  poly_g,
  input  wire [{0}:0]	 poly_f,
  output wire [{1}:0]  poly_out,
  output wire  		     done
);""".format(gf*num-1, gf*(num*2-1)-1))

print("")

print("wire [{0}:0] poly_med;".format(gf*num-1))

print("""
reg [{0}:0] poly_g_buffer = 0;

always @(posedge clk)
  begin
    poly_g_buffer <= start ? poly_g : poly_g_buffer;
  end
""".format(gf*num-1))

print("reg [4:0] counter = 5'b0;")
print("reg running = 1'b0;")

# use shift register instead
print("""
wire [{1}:0] f_i;
reg [{0}:0] f_shift = 0;

always @(posedge clk)
  begin
    f_shift <= start ? poly_f : (f_shift << {2});
  end

assign f_i = f_shift[{0}:{3}];""".format(gf*num-1, gf-1, gf, gf*(num-1)))


print("""
reg done_buffer = 0;

reg [{2}:0] poly_out_buffer = 0;

always @(posedge clk)
begin
  running <= start ? 1'b1 :
             done_buffer ? 1'b0 :
             running;

  counter <= start ? 5'b0 : 
             (counter == {0}) ? counter :
             running ? counter + 1 : counter;

  poly_out_buffer <= start ? {1}'b0: 
                     (counter == {0}) ? poly_out_buffer : 
                     ((poly_out_buffer << {3}) ^ poly_med);
end

assign poly_out = poly_out_buffer;""".format(num, gf*(num*2-1), gf*(num*2-1)-1, gf))

print("""

always @(posedge clk)
  begin
    done_buffer <= (counter == {0}) ? 1 : 0;
  end

assign done = done_buffer;
""".format(num-1))
 
for i in range(num):
	print("""gf_mul gf_mul_{0}_inst (
  .clk(clk),
  .dinA(poly_g_buffer[{1}:{2}]),
  .dinB(f_i),
  .dout(poly_med[{1}:{2}])
);
	""".format(i, gf*i+(gf-1), gf*i))
	
print("endmodule")
print("")

