/*
 * This file is top level sort module.
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

// generate secret permutation
// using the FieldOrdering approach.
// Part of the secret key generation

module field_ordering
  #(
    parameter M = 13,      // bit width of alphas
    parameter SIGMA2 = 32  // bit width of the randomly generated integers (for sorting)
  )
  (
    input wire clk,        // global clock signal
    input wire start,      // start generating the field ordering (suppoert - alphas)
    output wire done,      // done generating
    output wire fail,      // there was a failure - to sort values were equal!

    // write interface
    input wire wr_en,                  // write enable for random input data  - host_alpha_rand_wr_en in key_gen
    input wire [M-1:0] wr_addr,        // write address for input             - host_alpha_rand_wr_addr in key_gen
    input wire [SIGMA2-1:0] rand_in,   // input data                          - host_alpha_rand_data_in in key_gen
    
    // read interface
    input wire rd_en,                  // read enable to read data after done        - P_rd_en in decap
    input wire [M-1:0] rd_addr,        // read adddress for output                   - P_rd_addr in decap
    output wire [M-1:0] index_out,     // the field element at the requested input   - P_dout in decap

    output wire [SIGMA2-1:0] rand_dout // the corresponding random input data for sanity check
  );
 
  wire [M+SIGMA2-1:0] mem_dout;
  assign rand_dout = mem_dout[M+SIGMA2-1:M];
  assign index_out = mem_dout[M-1:0];
  
  wire [M-1:0] index_in;
  assign index_in = wr_addr;
  
  merge_sort #(.INT_WIDTH(SIGMA2), .INDEX_WIDTH(M), .LIST_LEN(1 << M), .FILE("")) merge_sort_inst (
    .clk(clk),
    .start(start),
    .wr_en(wr_en),
    .wr_addr(wr_addr),
    .data_in({rand_in, index_in}),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .data_out(mem_dout),
    .done(done),
    .fail(fail)
  );  
 
endmodule

 
