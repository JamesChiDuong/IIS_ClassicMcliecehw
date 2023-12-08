/*
 * This file is the testbench for the reduction module.
 *
 * Copyright (C) 2018s
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


`timescale 1ns/1ps

module reduction_tb;
  //inputs
  reg                      clk = 0;
  reg                      start = 0;
  reg [`num*`gf-1:0]       coeff_in = 0;
  reg                      rd_en = 0;
  reg [`num_power-1:0]     rd_addr = 0;
	
  //outputs
  wire                      done;
  wire [`mem_width*`gf-1:0] mem_coeff_A_dout_0;
  wire [`mem_width*`gf-1:0] mem_coeff_B_dout_0;
  
  
  reduction DUT (
    .clk(clk),
    .start(start),
    .coeff_in(coeff_in),
    .done(done),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .mem_coeff_A_dout_0(mem_coeff_A_dout_0),
    .mem_coeff_B_dout_0( mem_coeff_B_dout_0)
  );

  initial 
    begin
      $dumpfile("reduction_tb.vcd");
      $dumpvars(0, reduction_tb);
    end
  
  integer data_file;
  integer scan_file;
  
  initial
    begin
      data_file = $fopen("coeff_in.txt", "r");
      while (!$feof(data_file)) begin
        scan_file = $fscanf(data_file, "%b\n", coeff_in);
      end
    end
  
  integer start_time;
  integer total_time;
  integer last_total_time;
  
  initial
    begin
      start <= 0;
      # 25;
      start_time = $time;
      start <= 1;
      # 10;
      start <= 0;
      @(posedge DUT.init_done);
      total_time = $time;
      @(posedge done);
      $display("\nruntime: %0d cycles\n", ($time - start_time)/10);
      # 5;  
	    $writememb("data_out_A.txt",DUT.mem_coeff_A.mem);
	    $writememb("data_out_B.txt",DUT.mem_coeff_B.mem);
      # 5;
      $finish;
    end
  
  
	
	always @(posedge clk)
		begin
      @(posedge DUT.round_done);
      last_total_time = total_time;
      total_time = $time;
      $display("\nround %0d run time: %0d cycles\n", DUT.round_counter, (total_time-last_total_time)/10);
    end
  
  always 
    # 5 clk = !clk;

endmodule

