/*
 * This file is the testbench for the rad_conv+twist module.
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

`timescale 1ns / 1ps
module add_FFT_tb;
  // inputs
	reg                         clk = 0;
	reg                         start = 0;
  reg [`numc*`gf-1:0]          coeff_in = 0;
	reg                         rd_en = 0;
  reg [dep_bits-1:0]      rd_addr = 0;
	
  //outputs
	wire                        done;
  wire [2*`mem_width*`gf-1:0] data_out;
  
  localparam num = (1 << `CLOG2(`numc));
  localparam dep_bits = `CLOG2(`numc)-factor;
   
  add_FFT #(.numc(`numc), .gf(`gf), .mem_width(`mem_width)) DUT (
    .clk(clk),
    .start(start),
    .coeff_in(coeff_in),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .done(done),
    .data_out(data_out)
  );
  
  localparam factor = `CLOG2(`mem_width)-(`gf-`CLOG2(`numc)-1);
   
initial 
  begin
    $dumpfile("add_FFT_tb.vcd");
    $dumpvars(0, add_FFT_tb);
  end

integer data_file;
integer scan_file;

initial
  begin
    # 10;
    data_file = $fopen("coeff_in.txt", "r");
    # 10;
    while (!$feof(data_file)) begin
      scan_file = $fscanf(data_file, "%b\n", coeff_in);
    end
  end

integer start_time;

initial
  begin
    start <= 0;
    # 45;
    start_time = $time;
    start <= 1;
    # 10;
    start <= 0;
    @(posedge DUT.rad_conv_twisted_inst.done);
      $display("\nruntime of radix conversion: %0d cycles\n", ($time - start_time)/10);
    @(posedge done);
      $display("\nruntime of additive FFT: %0d cycles\n", ($time - start_time)/10);
    $writememb("eva_result_A", DUT.reduction_inst.mem_coeff_A.mem);
    $writememb("eva_result_B", DUT.reduction_inst.mem_coeff_B.mem);
    # 50;		
    $finish;
  end

always 
  # 5 clk = !clk;
	
endmodule

