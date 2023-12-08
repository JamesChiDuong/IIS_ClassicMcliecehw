/*
 * Function: additive FFT module.
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
*/


module add_FFT
#(
  parameter numc = 120,
  parameter gf = 13,
  parameter mem_width = 64, // number of multipliers used in reduction module

  // local:
  parameter factor = `CLOG2(mem_width)-(gf-`CLOG2(numc)-1),
  parameter num = (1 << `CLOG2(numc)),
  parameter dep_bits = `CLOG2(numc)-factor
)
(
  input wire                         clk,
  input wire                         start,
  input wire [numc*gf-1:0]          coeff_in,
  input wire                         rd_en,
  input wire [dep_bits-1:0]      rd_addr,
  
  output wire                        done,
  output wire [2*mem_width*gf-1:0] data_out
);
  
 
wire [numc*gf-1:0] coeff_out;
wire rad_done;

wire [mem_width*gf-1:0] mem_dout_A;
wire [mem_width*gf-1:0] mem_dout_B;
 
assign data_out = {mem_dout_B, mem_dout_A};
	
wire [num*gf-1:0] coeff_out_ex;
assign coeff_out_ex = {{gf*(num-numc){1'b0}}, coeff_out};
 
rad_conv_twisted rad_conv_twisted_inst (
  .clk(clk),
  .start(start),
  .coeff_in(coeff_in),
  .coeff_out(coeff_out),
  .done(rad_done)
);

reduction reduction_inst (
  .clk(clk),
  .start(rad_done),
  .coeff_in(coeff_out_ex),
  .done(done),
  .mem_coeff_A_dout_0(mem_dout_A), 
  .mem_coeff_B_dout_0(mem_dout_B),
  .rd_en(rd_en),
  .rd_addr(rd_addr)
);

endmodule

