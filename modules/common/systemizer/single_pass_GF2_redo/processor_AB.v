/*
 * This file is a sub module, processor_AB.
 * 
 * Copyright (C) 2016, 2022
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

`define OP_PASS 2'b00
`define OP_ADD  2'b01
`define OP_SWAP 2'b10

module processor_AB
(
  input  wire       clk,
  input  wire       rst,
  input  wire       functionA_in,
  output wire       functionA_out,
  input  wire       data_in,
  output wire       data_out,
  input  wire       swap_in,
  output wire       swap_out,
  input  wire [1:0] op_in,
  output wire [1:0] op_out,
  input  wire       check_in,
  output wire       check_out
);


  wire r_next;
  reg r_reg = 0;

  reg functionA_reg = 0;

  always @(posedge clk) begin
    if(rst) begin
      r_reg <= 0;
      functionA_reg <= 0;
    end
    else begin
      r_reg <= r_next;
      functionA_reg <= functionA_in;
    end
  end

  assign check_out = check_in & r_reg;

  assign swap_out = swap_in;

  assign functionA_out = functionA_reg;

  assign data_out = swap_in           ? r_reg :
                    functionA_reg     ? 1'b0 :
                    op_in == `OP_SWAP ? r_reg : 
                    op_in == `OP_ADD  ? (data_in ^ r_reg) : 
                    data_in;

  assign r_next = swap_in           ? data_in :
                  functionA_reg     ? (data_in==0 ? r_reg : 1'b1) :
                  op_in == `OP_SWAP ? data_in :
                  r_reg;

  assign op_out =  swap_in        ? `OP_SWAP :
                   !functionA_reg ? op_in : 
                   data_in==0     ? `OP_PASS : 
                   r_reg==0       ? `OP_SWAP :
                   `OP_ADD;

endmodule

