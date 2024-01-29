/*
 * This file is a sub module, pivot_cyc_mem.v, of the systemizer design.
 *     
 * Copyright (C) 2022
 * Authors: Ruben Niederhagen <ruben@polycephaly.org>
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

module pivot_cyc_mem
#(
  parameter N = 64,
  parameter L = 768
)
(
  input clk,
  input start_in,
  output reg start_out,
  input done_in,
  output reg done_out,
  input pivot,
  input wire [N-1 : 0] pivot_cmd,
  input wire [$clog2(L)-1:0] op_cyc_ctr,
  input wire [$clog2(L/N + 1) - 1 : 0] phase_id,
  output wire [($clog2(L)*N)-1:0] pivot_cyc_packed,
  // mem interface
  output wire [N-1:0] mem_data,
  input wire [N-1:0] mem_q,
  output wire [$clog2(L)*L/N-1:0] mem_addr,
  output wire mem_rden,
  output wire mem_wren
);

reg writing = 0;
reg reading = 0;
reg reading_del0 = 0;
reg reading_del1 = 0;
reg reading_del2 = 0;

reg [$clog2(L)-1:0] pivot_cyc [N-1:0];

integer i, j;
initial begin
  for (i=0;i<N;i=i+1) begin
    for (j=0;j<L/N;j=j+1)
      pivot_cyc[i] = 0;
  end
end

wire [N-1:0] data;
wire [N-1:0] q;

reg [$clog2(L+1)-1:0] addr = L;
reg [$clog2(L/N*$clog2(L))-1:0] offset = 0;

assign mem_addr = addr[$clog2(L)-1:0] + offset;
assign mem_data = data;
assign q = mem_q;
assign mem_wren = writing;
assign mem_rden = reading;

// mem mem_cyc (
//   .clock(clk),
//   .data(data),
//   .rdaddress(addr[$clog2(L)-1:0] + offset),
//   .rden(1'b1),
//   .wraddress(addr[$clog2(L)-1:0] + offset),
//   .wren(writing),
//   .q(q)
// );
// defparam mem_cyc.WIDTH = N;
// defparam mem_cyc.DEPTH = $clog2(L) * L/N;
// defparam mem_cyc.INIT = 1;

reg start_out_reg0 = 1'b0;
reg start_out_reg1 = 1'b0;
reg done_out_reg = 1'b0;

always @(posedge clk) begin
  start_out_reg0 <= pivot ? start_in : 
               reading && (addr == $clog2(L)-1) ? 1'b1 : 1'b0;

  start_out_reg1 <= start_out_reg0;
  start_out <= start_out_reg1;

  done_out_reg  <= !pivot ? done_in : 
               writing && (addr == $clog2(L)-1) ? 1'b1 : 1'b0;

  done_out <= done_out_reg;

  offset  <= phase_id*$clog2(L);
             //offset >= L/N * $clog2(L) ? 0 :
             //done_out ? offset + $clog2(L) : offset;

  writing <= pivot && done_in ? 1'b1 :
             (addr == $clog2(L)-1) ? 1'b0 : 
             writing;

  reading <= !pivot && start_in ? 1'b1 :
             (addr == $clog2(L)-1) ? 1'b0 : 
             reading;

  reading_del0 <= reading;
  reading_del1 <= reading_del0;

  reading_del2 <= reading_del1; //reading;

  addr <= (!pivot && start_in) || (pivot && done_in) ? 0 :
	  addr < $clog2(L) ? addr + 1 :
	  addr;
end

genvar gi;
for (gi=0; gi < N; gi=gi+1) begin : gen_pivot_cyc
  assign pivot_cyc_packed[(gi+1)*$clog2(L)-1:gi*$clog2(L)] = pivot_cyc[gi];

  assign data[gi] = pivot_cyc[gi][0];

  always @(posedge clk) begin
     pivot_cyc[gi] <= writing ? {pivot_cyc[gi][0], pivot_cyc[gi][$clog2(L)-1:1]} :
                      reading_del2 ? {q[gi], pivot_cyc[gi][$clog2(L)-1:1]} :
                      pivot_cmd[gi] ? op_cyc_ctr :
                      pivot_cyc[gi];
  end
end

endmodule

