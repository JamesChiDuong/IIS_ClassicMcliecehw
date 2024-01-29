
/*
 * This file is a sub module, processor_AB.
 * 
 * Copyright (C) 2016
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

module processor_AB
#(
  parameter WIDTH = 1
)
(
  input  wire             functionA,
  input  wire             first_pass,
  input  wire             pass,
  input  wire             clk,
  input  wire             rst,
  input  wire [WIDTH-1:0] data_in,
  input  wire [WIDTH-1:0] inv_in,
  input  wire             inv_en,
  input  wire             start_in,
  input  wire             finish_in,
  output wire             finish_out,
  input  wire [1:0]       op_in,
  output wire [1:0]       op_out,
  input  wire [WIDTH-1:0] fac_in,
  output wire [WIDTH-1:0] fac_out,
  output wire             start_out,
  output wire [WIDTH-1:0] data_out,
  output wire             r
);

  reg  [WIDTH-1:0] r_reg = 0;
  wire [WIDTH-1:0] r_tmp;

  always @(posedge clk) begin
    if (rst) begin
      r_reg <= 0;
    end
    else begin
      r_reg <= r_tmp;
    end
  end

  wire [WIDTH-1:0] mad_out;
  wire [WIDTH-1:0] inv_out;
//  wire inv_en;
//
//  GFE_inv gfe_inv_inst (
//    .clk(clk),
//    .din(data_in),
//    .dout(inv_out),
//    .dout_en(inv_en)
//  );

  assign inv_out = inv_in;

  GFE_mad gfe_mad_inst (
    .clk(clk),
    .dinA(op_in == 2'b11 ? data_in : r_reg),
    .dinB(fac_in),
    .dinC(op_in == 2'b11 ? {WIDTH{1'b0}} : data_in),
    .dout(mad_out)
  );

  assign data_out = pass           ? data_in :
                   (finish_in      ? r_reg :
                   (start_in       ? 0 : 
                   (functionA      ? 0 :
                   (op_in == 2'b00 ? data_in :    // pass
                   (op_in == 2'b01 ? r_reg :      // swap
                   (op_in == 2'b10 ? mad_out :    // add (elim input)
                   (op_in == 2'b11 ? r_reg :      // inv-add (set new r_reg; output current val)
                    0)))))));

  assign fac_out = functionA ? (r_reg[0] ? data_in : inv_out) : fac_in;

  assign r_tmp =  functionA      ? (r_reg[0] ? r_reg : 
                                   (inv_en & first_pass  ?     1 : 
                                    0)) :
                 (op_in == 2'b01 ? data_in :
                 (op_in == 2'b11 ? mad_out :
                  r_reg));

  assign op_out =  pass         ? 2'b00 :
                  ((!functionA) ? op_in :
                  (start_in     ? (inv_en ? 2'b11 : 2'b01) :
                  (finish_in    ? 2'b01 :
                  ((!inv_en)    ? 2'b00 :                    // data_in == 0
                  (r_reg[0]     ? 2'b10 : 2'b11)))));

  assign r = r_reg | pass;

  assign start_out  = start_in;

  assign finish_out = finish_in;

endmodule

