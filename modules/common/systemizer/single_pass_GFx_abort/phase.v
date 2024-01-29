
/*
 * This file is a sub module, step.v, which invokes the step module repeatedly.
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

module phase
#(
  parameter N = 4,
  parameter M = 1,
  parameter L = 8,
  parameter K = 16,
  parameter BLOCK = 4,
  parameter DATA = ""
)
(
  input  wire clk,
  input  wire rst,
  input  wire start,
  input  wire init_left,
  input  wire init_right,
  input  wire last_phase,
  input  wire [`CLOG2(K/N + 1) - 1 : 0] start_block,
  output wire done,
  output wire fail,
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

wire [`CLOG2(K/N + 1) - 1 : 0] step_counter_comp;
reg  [`CLOG2(K/N + 1) - 1 : 0] step_counter = 0;
reg  [`CLOG2(K/N + 1) - 1 : 0] col_block = 0;
reg  [`CLOG2(L*K/N+2*N + 1) - 1 : 0] first_pass_rows = 0;

reg start_step = 1'b0;
wire step_done;
reg last_step = 1'b0;

reg functionA = 1'b0;

reg done_reg = 1'b0;

reg running = 1'b0;
always @(posedge clk) begin
  running <= start || ((running && !(last_step && step_done))) && !fail;
end

assign step_counter_comp = start ? start_block :
                           !running ? 0 :
                           step_done ? (last_step ? 0 : step_counter + 1) :
                           step_counter;

reg [`CLOG2(K/N + 1) - 1 : 0] max_step = K/N-1;

always @(posedge clk) begin
  max_step     <=  init_left ? (L/N) : // Something is strange here; should be L/N-1.
                   init_right ? (K/N-1) :
                   max_step;

  last_step    <= (step_counter == max_step);

  step_counter <= step_counter_comp;

  col_block    <= step_counter_comp;

  first_pass_rows <= start ? L*start_block + L - N*start_block : first_pass_rows;

  start_step   <= start    ? 1'b1 :
                  !running ? 1'b0 :
                 (step_done && !last_step);

  functionA    <= start || (functionA && !step_done);

  done_reg     <= last_step && step_done;
end

assign done = done_reg;

step #(.N(N), .M(M), .L(L), .K(K), .BLOCK(BLOCK), .DATA(DATA)) step_inst (
  .rst(rst),
  .clk(clk),
  .start(start_step),
  .last_phase(last_phase),
  .first_pass_rows(first_pass_rows),
  .col_block(col_block),
  .functionA(functionA),
  .done(step_done),
  .fail(fail),
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

