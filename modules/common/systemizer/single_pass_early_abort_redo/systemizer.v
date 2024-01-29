/*
 * This file is a sub module, elim.v, which invokes the module phase iteratively.
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

module systemizer
#(
  parameter M=1,
  parameter BLOCK=-1,
  parameter N = 20,
  parameter L = 200,
  parameter K = 400,
  parameter DATA = ""
)
(
  input clk,
  input rst,
  output wire [1:0] gen_left_op,
  output wire [1:0] gen_right_op,
  input start,
  output wire fail,
  output wire success,
  input  wire start_right,
  output reg done,
  //output [N-1 : 0] mem_data_out,
  //output [3*N-1 : 0] mem_op_out,
  input  wire rd_en,
  input  wire [`CLOG2(L*K/N) - 1 : 0] rd_addr,
  output wire [(N*M)-1 : 0] data_out,
  input  wire wr_en,
  input  wire [`CLOG2(L*K/N) - 1 : 0] wr_addr,
    
`ifdef SHARED
  input wire                       host_pk_wr_en,
  input wire [`CLOG2(L*K/N) - 1 : 0]   host_pk_wr_addr, 
  input wire [(N*M)-1 : 0]   pk_din,
`endif

  input  wire [(N*M)-1 : 0] data_in
);

assign gen_left_op = 2'b01;
assign gen_right_op = 2'b10;

assign success = (last_block && phase_done) && left && ~fail_reg;

reg left = 1'b0;

reg [$clog2(L*K/N + 1) - 1 : 0] start_block = 0;
reg [$clog2(L*K/N + 1) - 1 : 0] end_block = 0;

reg [$clog2(L/N + 1) - 1 : 0] phase_counter = 0;

reg  start_phase = 1'b0;
wire phase_done;
reg  last_block = 1'b0;

reg [`CLOG2(L) : 0] rows = 0;

reg fail_reg = 1'b0;
wire phase_fail;

reg running = 1'b0;
always @(posedge clk) begin
  running <= start || start_right || (running && !(last_block && phase_done));
end

assign fail = (last_block && phase_done) && fail_reg;

always @(posedge clk) begin
  left          <= start ? 1'b1 :
	           start_right ? 1'b0 :
		   left;

  last_block    <= (start_block == L*(L/N-1));

  phase_counter <= start||start_right ? 0 : 
                   !running ? 0 :
                   phase_done ? (last_block ? phase_counter : phase_counter + 1) :
                   phase_counter;

  start_block <= start||start_right ? 0 : 
                   !running ? 0 :
                   phase_done ? (last_block ? start_block : start_block + L) :
                   start_block;

  start_phase   <= start||start_right    ? 1'b1 :
                   !running ? 1'b0 :
                   (phase_done && !last_block);

  end_block     <= start ? L*L/N :
	           start_right ? L*K/N :
		   end_block;

  rows          <= start||start_right ? L :
                   !running ? L :
                   (rows == N) ? N :
                   phase_done ? rows - N :
                   rows;

  fail_reg      <= start||start_right ? 1'b0 :
                   phase_fail ? 1'b1 :
                   fail_reg;
                   
  done          <= (last_block && phase_done) && !left;
end

phase phase_inst (
  .rst(rst),
  .clk(clk),
  .start(start_phase),
  .pivot(left),
  .phase(phase_counter),
  .start_block(start_block),
  .end_block(end_block),
  .done(phase_done),
  .rd_en(rd_en),
  .rd_addr(rd_addr),
  .data_out(data_out),
  .wr_en(wr_en),
  .wr_addr(wr_addr),
  .data_in(data_in),
  .rows(rows),
  
// public key input used in joint design 
`ifdef SHARED
  .host_pk_wr_en(host_pk_wr_en),     
  .host_pk_wr_addr(host_pk_wr_addr), 
  .pk_din(pk_din),
`endif

  .fail(phase_fail)
);
defparam phase_inst.N = N;
defparam phase_inst.L = L;
defparam phase_inst.K = K;

endmodule

