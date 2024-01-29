
/*
 * This file is a sub module, elim.v, which invokes the module phase iteratively.
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

module systemizer
#(
  parameter N = 20,
  parameter M = 1,
  parameter L = 200,
  parameter K = 400,
  parameter BLOCK = 4,
  parameter DATA = ""
)
(
  input  wire clk,
  input  wire rst,
  output wire [1:0] gen_left_op,
  output wire [1:0] gen_right_op,
  input  wire start,
  output wire fail,
  output wire success,
  input  wire start_right,
  output wire done,
  input  wire rd_en,
  input  wire [`CLOG2(L*K/N) - 1 : 0] rd_addr,
  output wire [(N*M)-1 : 0] data_out,
  input  wire wr_en,
  input  wire [`CLOG2(L*K/N) - 1 : 0] wr_addr,
  input  wire [(N*M)-1 : 0] data_in,
    
  input wire                       host_pk_wr_en,
  input wire [`CLOG2(L*K/N) - 1 : 0]   host_pk_wr_addr, 
  input wire [(N*M)-1 : 0]   pk_din
);

// This implementation does not have a second pass in the right side.
assign gen_left_op = 2'b01;
assign gen_right_op = 2'b00;

reg check = 1'b0;

reg [`CLOG2(K/N + 1) - 1 : 0] phase_counter = 0;

reg  start_phase = 1'b0;
wire phase_done;
reg  last_phase = 1'b0;

reg success_reg = 1'b0;
reg done_reg = 1'b0;

wire phase_fail;
reg fail_reg = 1'b0;

reg running = 1'b0;
always @(posedge clk) begin
  running <= start || start_right || ((running && !(last_phase && phase_done))) & !fail;
end

always @(posedge clk) begin
  check         <= start ? 1'b1 :
                   start_right ? 1'b0 : 
                   check;

  fail_reg      <= start || start_right ? 1'b0 : 
                   phase_fail ? 1'b1 :
                   fail_reg ? 1'b0 :
                   fail_reg;

  last_phase    <= phase_counter == (L+N-1)/N-1;

  phase_counter <= start || start_right ? 0 : 
                   !running ? 0 :
                   phase_done ? (last_phase ? 0 : phase_counter + 1) :
                   phase_counter;

  start_phase   <= start || start_right   ? 1'b1 :
                   !running ? 1'b0 :
                   (phase_done && !last_phase); 

  done_reg      <= check ? 1'b0 : (last_phase && phase_done) || phase_fail;

  success_reg   <= fail ? 1'b0 : ((last_phase && phase_done) || phase_fail) & check;
end

assign done = done_reg;
assign fail = fail_reg;
assign success = success_reg;

phase #(.N(N), .M(M), .L(L), .K(K), .BLOCK(BLOCK), .DATA(DATA)) phase_inst (
  .rst(rst),
  .clk(clk),
  .start(start_phase),
  .init_left(start),
  .init_right(start_right),
  .last_phase(last_phase & (L%N > 0)),
  .start_block(phase_counter),
  .done(phase_done),
  .fail(phase_fail),
  .rd_en(rd_en),
  .rd_addr(rd_addr),
  .data_out(data_out),
  .wr_en(wr_en),
  .wr_addr(wr_addr),
  .data_in(data_in),
  
  // public key input used in joint design 
  .host_pk_wr_en(host_pk_wr_en),     
  .host_pk_wr_addr(host_pk_wr_addr), 
  .pk_din(pk_din)
);
  
endmodule

