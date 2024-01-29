/*
 * This file is a sub module, processor_B.
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

module processor_B (
  input  wire       clk,
  input  wire       rst,
  input  wire       data_in,
  input  wire [1:0] op_in,
  output wire [1:0] op_out,
  output wire        data_out
);

  wire r_next;
  reg r_reg = 0;
 
  always @(posedge clk) begin
    //if(rst) begin
    //  r_reg <= 0;
    //end
    //else begin
      r_reg <= r_next;
    //end
  end


  assign data_out = op_in == `OP_SWAP ? r_reg : 
                    op_in == `OP_ADD  ? data_in ^ r_reg : 
                    data_in;

  assign r_next = rst ? 1'b0 : 
	          op_in == `OP_SWAP ? data_in :
                  r_reg;

  assign op_out = op_in;

  //always @(*) begin
  //    case(op_in)
  //        OP_PASS: begin
  //            r_next = r_reg;
  //            data_out = data_in;
  //        end
  //        OP_ADD:  begin
  //            r_next = r_reg;
  //            data_out = data_in ^ r_reg;
  //        end
  //        OP_SWAP: begin
  //            r_next = data_in;
  //            data_out = r_reg;
  //        end
  //    endcase
  //end

  // LUT6_2 #(
  //         .INIT(64'h3333333355555555)
  // ) LUT6_2_inst (
  //         .O6(r_next), 
  //         .O5(data_out), 
  //         .I0(op_in[0]), 
  //         .I1(op_in[1]), 
  //         .I2(r_reg), 
  //         .I3(data_in), 
  //         .I4(rst), 
  //         .I5(1'b1) 
  // );


endmodule

