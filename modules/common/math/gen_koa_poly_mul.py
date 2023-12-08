'''
 * Function: generate Karatsuba polynomial multiplication module.
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

# Function: code generation tool for 6-split Karatsuba polynomial multiplication module
 
import argparse

parser = argparse.ArgumentParser(description='Generate 6-split Karatsuba poly_mul module.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required= True,
          help='number of coeffs of the polynomial')
parser.add_argument('-m','--gf', dest='gf', type=int, required= True, default=13,
          help='field 2^m')
args = parser.parse_args()

num = args.n
gf = args.gf
sec = int(num/6)

print("//6-split Karatsuba polynomial multiplication\n")
print("""module poly_mul_koa (
  input  wire            start,
  input  wire	 		       clk,
  input  wire [{0}:0]    poly_g,
  input  wire [{0}:0]	   poly_f,
  output wire [{1}:0]    poly_out,
  output wire			       done,
  output wire            poly_done
);
""".format(gf*num-1, gf*(2*num-1)-1))

for i in range(6):
  print("wire [{0}:0] g{1};".format(gf*sec-1, i))

print("")

for i in range(6):
  print("assign g{0} = poly_g[{1}:{2}];".format(i, (i+1)*gf*sec-1, i*gf*sec))
 
print("")

for i in range(6):
  print("wire [{0}:0] f{1};".format(gf*sec-1, i))

print("")

for i in range(6):
   print("assign f{0} = poly_f[{1}:{2}];".format(i, (i+1)*gf*sec-1, i*gf*sec))
 
print("")

print("""
reg [4:0] counter = 5'b0;

reg [5:0] gf_mask[0:17];

initial
  begin
    gf_mask[0] = 6'b111111;
    gf_mask[1] = 6'b110110;
    gf_mask[2] = 6'b101101;
    gf_mask[3] = 6'b101001;
    gf_mask[4] = 6'b100101;
    gf_mask[5] = 6'b111000;
    gf_mask[6] = 6'b000111;
    gf_mask[7] = 6'b001100;
    gf_mask[8] = 6'b010010;
    gf_mask[9] = 6'b011000;
    gf_mask[10] = 6'b000110;
    gf_mask[11] = 6'b110000;
    gf_mask[12] = 6'b000011;
    gf_mask[13] = 6'b100000;
    gf_mask[14] = 6'b010000;
    gf_mask[15] = 6'b000010;
    gf_mask[16] = 6'b000001;
    gf_mask[17] = 6'b000000;
  end

wire [5:0] gf_dout;
assign gf_dout = gf_mask[counter];

reg [11:0] out_mask[0:16];

initial
  begin
    out_mask[0] = 12'b000000010000;
    out_mask[1] = 12'b100001010000;
    out_mask[2] = 12'b100011101000;
    out_mask[3] = 12'b100011110000;
    out_mask[4] = 12'b100000101000;
    out_mask[5] = 12'b100100001000;
    out_mask[6] = 12'b100011010100;
    out_mask[7] = 12'b100011011000;
    out_mask[8] = 12'b100001100000;
    out_mask[9] = 12'b100110011000;
    out_mask[10] = 12'b100010011100;
    out_mask[11] = 12'b101101001000;
    out_mask[12] = 12'b100011000110;
    out_mask[13] = 12'b111000110000;
    out_mask[14] = 12'b101011111000;
    out_mask[15] = 12'b100010101010;
    out_mask[16] = 12'b100000110011;
  end
  
wire [11:0] out_dout;
assign out_dout = out_mask[counter];
""")
 
print("wire [{0}:0] g_in;".format(gf*sec-1))

str_g = "(gf_dout[5] ? g0 : 0)";
str_f = "(gf_dout[5] ? f0 : 0)";

for i in range(5):
  str_g += " ^ (gf_dout[{1}] ? g{0} : 0)".format(i+1, 4-i)
  str_f += " ^ (gf_dout[{1}] ? f{0} : 0)".format(i+1, 4-i)

str_g += ";"
str_f += ";"

print("""reg running = 0;
 
assign g_in = (!running) ? 0 : {0}
""".format(str_g)) 

print("")

print("wire [{0}:0] f_in;".format(gf*sec-1))

print("""assign f_in = (!running) ? 0 : {0}
""".format(str_f)) 

print("")

#print("wire poly_done;")

print("wire [{0}:0] R_out;".format(gf*(sec*2-1)-1))

out_str = "(out_dout[11] ? poly_out_buffer : 0)"

for i in range(11):
  out_str += " ^ (out_dout[{1}] ? (R_out << {0}) : 0)".format(gf*sec*i, 10-i)

 
print("""
always @(posedge clk)
  begin
    running <= start ? 1'b1 : 
               done ? 1'b0 :
               running;  
  end

always @(posedge clk)
  begin
    counter <= start ? 0 :
               poly_done ? counter + 1 :
               done ? 0 :
               counter;
  end
                 
reg [{0}:0] poly_out_buffer = 0;

always @(posedge clk)
  begin
    poly_out_buffer <= start ? 0 :
                       poly_done ? {1} :
											  poly_out_buffer;
  end

assign poly_out = poly_out_buffer;
""".format(gf*(6*2*sec-1)-1, out_str))

print("""
reg poly_start = 0;

always @(posedge clk)
  begin
    poly_start <= (start | ((counter < 16) && poly_done));
  end
""")

print("""
reg done_buffer = 0;

always @(posedge clk)
  begin
    done_buffer <= ((counter == {0}) && poly_done) ? 1'b1 : 1'b0;
  end

assign done = done_buffer;
""".format(16))

print("")

print("""poly_mul_sb poly_mul_sb_inst (
  .start(poly_start),
  .clk(clk),
  .poly_g(g_in),
  .poly_f(f_in),
  .poly_out(R_out),
  .done(poly_done)
);
""") 

 

print("endmodule")
print("")

