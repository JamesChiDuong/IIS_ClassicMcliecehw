/*
 * This file is evaluates the input error locator polynomial and output the error bits.
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


module error_locator
  # (
    parameter m = 13, //2^m is the size of the finite field, m=13
    parameter n = 6960, // code length
    parameter t = 119, // number of errors

    parameter eva_mem_WIDTH = m*(1 << (m-`CLOG2(t+1))), //memory width in the add_FFT module
    parameter eva_mem_WIDTH_bits = m-`CLOG2(t+1),
    parameter eva_mem_DEPTH = (1 << `CLOG2(t+1)), //memory depth in the add_FFT module
    parameter eva_mem_DEPTH_bits = `CLOG2(t+1)
  )
  (
    input  wire                        clk,
    input  wire                        start,
    output wire [n-1:0]                error_recovered,
    output wire                        done,

    // interface with add_FFT memory
    input  wire [eva_mem_WIDTH-1:0]    eva_dout,
    output wire                        eva_rd_en,
    output wire [`CLOG2(t+1)-1:0]      eva_rd_addr,

    // interface with permutation P memory
    input  wire [m-1:0]                P_dout,
    output wire                        P_rd_en,
    output wire [m-1:0]                P_rd_addr,   // here we assume that SK P is stored in a m*n memory

    output  reg [m*t-1:0]              P_rd_addr_re_encrypt = {m*t{1'b0}},
    output  reg [`CLOG2(t):0]          error_hamming_weight = {(`CLOG2(t)+1){1'b0}}
  );

  reg running = 1'b0;
  reg [`CLOG2(n):0] counter = {(`CLOG2(n)+1){1'b0}};

  always @(posedge clk)
    begin
      counter <= start ? {(`CLOG2(n)+1){1'b0}} :
                 (counter < n) ? counter + 1 :
                 counter;

      running <= start ? 1'b1 :
                 (counter >= (n-1)) ? 1'b0 :
                  running;
    end

  assign P_rd_en = running;
  assign P_rd_addr = counter;


  reg running_buffer = 1'b0;
  reg eva_rd_en_buffer = 1'b0;
  reg point_loc_start = 1'b0;

  always @(posedge clk)
    begin
      running_buffer <= running;
      eva_rd_en_buffer <= running_buffer;
      point_loc_start <= eva_rd_en_buffer;
    end

  assign eva_rd_en = eva_rd_en_buffer;

  reg [eva_mem_DEPTH_bits-1:0] eva_rd_addr_buffer = {eva_mem_DEPTH_bits{1'b0}};
  reg [eva_mem_WIDTH_bits-1:0] eva_rd_loc_buffer = {eva_mem_WIDTH_bits{1'b0}};
  reg [eva_mem_WIDTH_bits-1:0] eva_rd_loc = {eva_mem_WIDTH_bits{1'b0}};

  always @(posedge clk)
    begin
     eva_rd_addr_buffer <= (P_dout >> eva_mem_WIDTH_bits);
     eva_rd_loc_buffer <= (P_dout % (1 << eva_mem_WIDTH_bits));
     eva_rd_loc <= eva_rd_loc_buffer;
    end

  assign eva_rd_addr = eva_rd_addr_buffer;

  reg [n-1:0] error_recovered_buffer = {n{1'b0}};
  reg done_buffer = 1'b0;

  wire [m-1:0] check_value;
  wire loc_done;
  reg [m-1:0] error_counter = {m{1'b0}};
  
  always @(posedge clk)
    begin
      error_counter <= start ? {m{1'b0}} :
                       (loc_done & (error_counter < n)) ? error_counter + 1 :
                       error_counter;

      error_recovered_buffer <= {error_recovered_buffer[n-2:0], (check_value == {m{1'b0}})};

      done_buffer <= start ? 1'b0 :
                     (error_counter == (n-1));

      P_rd_addr_re_encrypt <= start ? {m*t{1'b0}} :
                              loc_done & (check_value == {m{1'b0}}) ? {P_rd_addr_re_encrypt[m*(t-1)-1:0], error_counter} :
                              P_rd_addr_re_encrypt;

      error_hamming_weight <= start ? {(`CLOG2(t)+1){1'b0}} :
                              loc_done & (check_value == {m{1'b0}}) ? error_hamming_weight + 1 :
                              error_hamming_weight;
    end

  assign error_recovered = error_recovered_buffer;
  assign done = done_buffer;

  point_loc point_loc_error_loc_inst (
    .start(point_loc_start),
    .clk(clk),
    .location(eva_rd_loc),
    .data_in(eva_dout),
    .data_out(check_value),
    .done(loc_done)
  );

endmodule

