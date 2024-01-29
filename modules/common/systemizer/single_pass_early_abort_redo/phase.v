/*
 * This file is a sub module, step.v, which invokes the step module repeatedly.
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

module phase
#(
  parameter N = 4,
  parameter L = 8,
  parameter K = 16,
  parameter JOINT_MEMORY = 1
)
(
  input clk,
  input rst,
  input start,
  input pivot,
  input [$clog2(L/N + 1) - 1 : 0] phase,
  input [$clog2(L*K/N + 1) - 1 : 0] start_block,
  input [$clog2(L*K/N + 1) - 1 : 0] end_block,
  output wire done,
  input  wire rd_en,
  input  wire [`CLOG2(L*K/N) - 1 : 0] rd_addr,
  output wire [N-1 : 0] data_out,
  input  wire wr_en,
  input  wire [`CLOG2(L*K/N) - 1 : 0] wr_addr,
  input  wire [N-1 : 0] data_in,
  input wire [`CLOG2(L) : 0] rows,
    
`ifdef SHARED
  input wire                       host_pk_wr_en,
  input wire [`CLOG2(L*K/N) - 1 : 0]  host_pk_wr_addr, 
  input wire [N-1 : 0]   pk_din,
`endif

  output wire fail
);

// N: size of the architecture
// L: row number of the matrix
// K: column number of the matrix

generate
if (N < 4) begin
    ERROR_N_must_be_larger_than_4 ASSERT_ERROR();
end
if (L < 3*N) begin
    ERROR_L_must_be_at_least_three_times_N ASSERT_ERROR();
end
endgenerate


wire start_int;

reg done_int = 0;

reg [$clog2(L*K/N+2*N + 1) - 1 : 0] row_counter = 0;
reg [$clog2(L*K/N+2*N + 1) - 1 : 0] row_counter_end = 0;
reg [$clog2(L*K/N+2*N + 1) - 1 : 0] start_row = 0;
reg [$clog2(L*K/N+2*N + 1) - 1 : 0] last_row_out;

reg [$clog2(L*K/N) - 1 : 0] addr_op_start = 0;
reg [$clog2(L*K/N) - 1 : 0] addr_op_end = L-1;

reg [$clog2(L)-1:0] op_cyc_ctr = 0;

reg pivoting = 1'b0;
reg [2*N+1 : 0] pivoting_comp = 0;

reg running = 1'b0;
always @(posedge clk) begin
  running <= start_int ? 1'b1 :
             row_counter == row_counter_end ? 1'b0 :
             running;
end

wire pivot_step;
assign pivot_step = start_int && pivot;

reg pivot_done = 1'b0;

always @(posedge clk) begin
  op_cyc_ctr       <= start_int && !pivot ? L-1 :
                      !running ? 0 :
                      op_cyc_ctr < L-1 ? op_cyc_ctr + 1 :
                      0;

  pivot_done       <= op_cyc_ctr == L-1;

  pivoting_comp[0] <= pivot_step ? 1'b1 :
                      pivot_done ? 1'b0 :
                      pivoting_comp[0];

  pivoting         <= pivoting_comp[0] ? 1'b1 : 
                      pivoting_comp[2*N-2];

  start_row        <= start ? 
                        (pivot ? start_block : L*L/N-1) :
                      start_row;

  row_counter_end      <= start ? end_block + 2*N : row_counter_end;

  addr_op_start <= start ? start_block : addr_op_start;
  addr_op_end   <= start ? start_block + L-1 : addr_op_end;

  done_int         <= (row_counter == row_counter_end) ? running : 0;

  row_counter      <= start ?
                        (pivot ? start_block : L*L/N-1) :
                      running   ? row_counter + 1 : row_counter;

  last_row_out     <= start ? start_block + rows + N + 1 : last_row_out;
end


// M20k interface data
reg  [N - 1 : 0] din_data = 0;
wire [N - 1 : 0] dout_data;

reg [$clog2(L*K/N) - 1 : 0] rd_addr_data = 0;
reg [$clog2(L*K/N) - 1 : 0] wr_addr_data = 0;
reg rd_en_data = 1'b0;
reg wr_en_data;

// M20k interface op
reg  [N - 1 : 0] din_op = 0;
wire [N - 1 : 0] dout_op;

reg [$clog2(L*K/N) - 1 : 0] rd_addr_op = 0;
reg [$clog2(L*K/N) - 1 : 0] wr_addr_op = 0;
reg rd_en_op = 0;
reg wr_en_op;

reg [N-1:0] piv_mem_q;

reg [N-1:0] piv_mem_data_reg;
reg [$clog2(L)*L/N-1:0] piv_mem_addr_reg;
reg piv_mem_rden_reg;
reg piv_mem_wren_reg;

wire [N-1:0] piv_mem_data;
wire [$clog2(L)*L/N-1:0] piv_mem_addr;
wire piv_mem_rden;
wire piv_mem_wren;

generate
  if (JOINT_MEMORY == 1) // use a joint memory for both data and pivot ctr values
    begin
      mem_quad mem_data (
        .clk (clk),
      //

`ifdef SHARED
        .data0 (host_pk_wr_en? pk_din :piv_mem_wren_reg ? piv_mem_data_reg : din_op),
        .wraddress0 (host_pk_wr_en? host_pk_wr_addr :piv_mem_wren_reg ? piv_mem_addr_reg : wr_addr_op),
        .wren0 (host_pk_wr_en? host_pk_wr_en :piv_mem_wren_reg ? piv_mem_wren_reg : wr_en_op),
`else
        .data0 (piv_mem_wren_reg ? piv_mem_data_reg : din_op),
        .wraddress0 (piv_mem_wren_reg ? piv_mem_addr_reg : wr_addr_op),
        .wren0 (piv_mem_wren_reg ? piv_mem_wren_reg : wr_en_op),
`endif
      //
        .rdaddress0 (piv_mem_rden_reg ? piv_mem_addr_reg : rd_addr_op),
        .rden0 (piv_mem_rden_reg ? piv_mem_rden_reg : rd_en_op),
        .q0 (dout_op),
      //
        .data1 (wr_en ? data_in : din_data),
        .wraddress1 (wr_en ? wr_addr : wr_addr_data),
        .wren1 (wr_en ? wr_en : wr_en_data),
      //
        .rdaddress1 (rd_en ? rd_addr : rd_addr_data),
        .rden1 (rd_en ? rd_en : rd_en_data),
        .q1 (dout_data)
      );
      defparam mem_data.WIDTH = N;
      defparam mem_data.DEPTH = L*K/N + $clog2(L) * L/N;
      defparam mem_data.INIT = 1;
      
      assign data_out = dout_data;
      
      always @(posedge clk) begin
         piv_mem_q <= dout_op;

         piv_mem_data_reg <= piv_mem_data;
         piv_mem_addr_reg <= L*K/N + piv_mem_addr;
         piv_mem_rden_reg <= piv_mem_rden;
         piv_mem_wren_reg <= piv_mem_wren;
      end
    end
  else
    begin              // use a individual memories for data and pivot ctr values
      mem_quad mem_data (
        .clk (clk),
      //
        .data0 (host_pk_wr_en? pk_din :din_op),
        .wraddress0 (host_pk_wr_en? host_pk_wr_addr :wr_addr_op),
        .wren0 (host_pk_wr_en? host_pk_wr_en :wr_en_op),
      //
        .rdaddress0 (rd_addr_op),
        .rden0 (rd_en_op),
        .q0 (dout_op),
      //
        .data1 (wr_en ? data_in : din_data),
        .wraddress1 (wr_en ? wr_addr : wr_addr_data),
        .wren1 (wr_en ? wr_en : wr_en_data),
      //
        .rdaddress1 (rd_en ? rd_addr : rd_addr_data),
        .rden1 (rd_en ? rd_en : rd_en_data),
        .q1 (dout_data)
      );
      defparam mem_data.WIDTH = N;
      defparam mem_data.DEPTH = L*K/N + $clog2(L) * L/N;
      defparam mem_data.INIT = 1;
      
      assign data_out = dout_data;
      
      mem pivot_cyc_memory (
        .clock(clk),
        .data(piv_mem_data),
        .rdaddress(piv_mem_addr),
        .rden(piv_mem_rden),
        .wraddress(piv_mem_addr),
        .wren(piv_mem_wren),
        .q(piv_mem_q)
      );
      defparam pivot_cyc_memory.WIDTH = N;
      defparam pivot_cyc_memory.DEPTH = $clog2(L) * L/N;
      defparam pivot_cyc_memory.INIT = 1;
    end
endgenerate

///////////////////////////////////////

// com_SA module
reg SA_start = 0;

reg [N-1 : 0] SA_din;
reg [2*N-1:0] SA_op_in;

wire [N-1 : 0] SA_dout;
wire [2*N-1 : 0] SA_op_out;

reg SA_data_en = 1'b0;
reg SA_op_en   = 1'b0;

reg [2*N+1:0] SA_out_en;

wire check_out;

comb_SA comb_SA_inst (
  .clk (clk),
  .rst (rst),
  .functionA (pivoting_comp[1]),
  .swap(SA_start),
  .op_in (SA_op_in),
  .data (SA_din),
  .data_out(SA_dout),
  .op_out (SA_op_out),
  .check_in(1'b1),
  .check_out(check_out)
);

assign fail = (row_counter == last_row_out) ? !check_out && pivoting : 1'b0;

wire [($clog2(L)*N)-1:0] pivot_cyc_packed;

wire [$clog2(L)-1:0] pivot_cyc [N-1:0];

wire [N-1 : 0] pivot_cmd;

pivot_cyc_mem pivot_cyc_mem_inst (
  .clk(clk),
  .pivot(pivot),
  .start_in(start),
  .start_out(start_int),
  .done_in(done_int),
  .done_out(done),
  .pivot_cmd(pivot_cmd),
  .op_cyc_ctr(op_cyc_ctr),
  .phase_id(phase),
  .pivot_cyc_packed(pivot_cyc_packed),
  // mem interface
  .mem_data(piv_mem_data),
  .mem_q(piv_mem_q),
  .mem_addr(piv_mem_addr),
  .mem_rden(piv_mem_rden),
  .mem_wren(piv_mem_wren)
);
defparam pivot_cyc_mem_inst.N = N;
defparam pivot_cyc_mem_inst.L = L;


genvar gi;
for (gi=0; gi < N; gi=gi+1) begin
  assign pivot_cyc[gi] = pivot_cyc_packed[(gi+1)*$clog2(L)-1:gi*$clog2(L)];
end

for (gi=0; gi < 2*N+1; gi=gi+1) begin : gen_SA_out_en
  always @(posedge clk) begin
     SA_out_en[gi+1] <= SA_out_en[gi];
     pivoting_comp[gi+1] <= pivoting_comp[gi];
  end
end

for (gi=0; gi < N; gi=gi+1) begin : gen_pivot_cyc
  assign pivot_cmd[gi] = pivoting_comp[gi*2+1] && SA_op_out[gi*2+1];

  always @(posedge clk) begin
     din_op[gi]    <= SA_op_out[gi*2];

     SA_op_in[2*gi]   <= dout_op[gi];
     SA_op_in[2*gi+1] <= (op_cyc_ctr == 2*(gi+1)-1) || (op_cyc_ctr == pivot_cyc[gi]-1);
  end
end

always @(posedge clk) begin
  SA_out_en[0] <= SA_data_en && !pivoting_comp[0] ? 1'b1 : 
                  1'b0;

  SA_din       <= dout_data;

  // in fact the same as row_counter
  rd_addr_data <= start_int ? start_row :
                  rd_en_data ? rd_addr_data + 1 : rd_addr_data;
  rd_en_data   <= start_int ? 1'b1 : 
                  row_counter == end_block ? 1'b0 :
                  rd_en_data;

  SA_data_en   <= rd_en_data;

  rd_addr_op   <= op_cyc_ctr == 2*N-2 ? addr_op_start + 2*N : 
                  rd_en_op && (rd_addr_op < addr_op_end) ? rd_addr_op + 1 : addr_op_start;
  rd_en_op     <= start_int || running;

  SA_op_en     <= rd_en_op;


  wr_en_op     <= pivoting;
  wr_addr_op   <= wr_en_op && (wr_addr_op < addr_op_end) ? wr_addr_op + 1 : addr_op_start;


  din_data     <= SA_dout;

  wr_en_data   <= pivot ? SA_out_en[2*N] : SA_out_en[2*N+1];
  //wr_en_data   <= SA_out_en[2*N];
  wr_addr_data <= start_int ? 
                     (pivot ? start_row + L : start_row + 1) :
                  wr_en_data ? wr_addr_data + 1 : wr_addr_data;

  SA_start     <= op_cyc_ctr == 1;
end

endmodule

