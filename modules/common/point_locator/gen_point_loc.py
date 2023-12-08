'''
   This file is the code generation file for module comb_SA.v

   Copyright (C) 2018
   Authors: Wen Wang <wen.wang.ww349@yale.edu>
            Ruben Niederhagen <ruben@polycephaly.org>
  
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
  
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
  
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

'''

import sys
import math
import argparse

parser = argparse.ArgumentParser(description='Generate point_loc module: finding g(a) in add_FFT.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
 
parser.add_argument('-t', dest='t', type=int, default=119,  
          help='number of errors; default = 119')
   
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
 
args = parser.parse_args()

t = args.t
m = args.m

DEPTH_bits = int(math.ceil(math.log(t+1, 2)))
WIDTH_bits = m-DEPTH_bits
WIDTH = m*int(math.pow(2, WIDTH_bits))


print("""
// read out corresponding g(a) values

module point_loc (
  input wire          start,
  input wire          clk,
  input wire [{0}:0]  location,
  input wire [{1}:0]  data_in,
  output wire [{2}:0] data_out,
  output wire         done
);
""".format(WIDTH_bits-1, WIDTH-1, m-1))

for i in range(WIDTH_bits+1):
  print("reg [{0}:0] data_{1}_reg = {2}'b0;".format(int(WIDTH/math.pow(2, i))-1, int(math.pow(2, (WIDTH_bits-i))), int(WIDTH/math.pow(2, i))))

print("\n")

for i in range(WIDTH_bits):
  print("reg [{0}:0] location_{1}_reg = {2}'b0;".format(WIDTH_bits-1, int(math.pow(2, (WIDTH_bits-i))), WIDTH_bits))

print("""
always @(posedge clk)
  begin""")

for i in range(WIDTH_bits+1):
  if (i == 0):
    print("""    location_{0}_reg <= start ? location : location_{0}_reg;
    data_{0}_reg <= start ? data_in : data_{0}_reg;
""".format(int(math.pow(2, (WIDTH_bits-i)))))
  else:
    print("    data_{0}_reg <= (location_{1}_reg >> {2}) ? data_{1}_reg[{3}:{4}] : data_{1}_reg[{5}:0];".format(int(math.pow(2, (WIDTH_bits-i))), 2*int(math.pow(2, (WIDTH_bits-i))), WIDTH_bits-i, 2*int(math.pow(2, (WIDTH_bits-i)))*m-1, int(math.pow(2, (WIDTH_bits-i)))*m, int(math.pow(2, (WIDTH_bits-i)))*m-1))
    if (i < WIDTH_bits):
      print("    location_{0}_reg <= (location_{1}_reg >> {2}) ? (location_{1}_reg - {0}) : location_{1}_reg;\n".format(int(math.pow(2, (WIDTH_bits-i))), 2*int(math.pow(2, (WIDTH_bits-i))), WIDTH_bits-i))

print("\n  end")

print("")
for i in range(WIDTH_bits+1):
  print("reg done_{0} = 1'b0;".format(i))
print("")

print("""always @(posedge clk)
  begin""")
for i in range(WIDTH_bits+1):
  if (i == 0):
  	print("    done_0 <= start;")
  else:
  	print("    done_{0} <= done_{1};".format(i, i-1))
print("  end")

print("""
assign data_out = data_1_reg;
assign done = done_{0};

endmodule
""".format(WIDTH_bits))
