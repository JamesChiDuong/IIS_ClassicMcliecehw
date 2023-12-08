/*
 * This file is the testbench for BM module.
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


`timescale 1ns/1ps

module BM_tb;
  
  // inputs
  reg clk = 1'b0;
  reg start = 1'b0;
  wire [`m-1:0] synd_dout;
  
  // outputs
  wire synd_rd_en;
  wire [`CLOG2(2*`t)-1:0] synd_rd_addr;
  wire [`m*(`t+1)-1:0] error_loc_poly;
  wire done;
  
  BM #(.m(`m), .t(`t), .mul_sec_BM(`mul_sec_BM), .mul_sec_BM_step(`mul_sec_BM_step)) DUT (
    .clk(clk),
    .start(start),
    .synd_dout(synd_dout),
    .synd_rd_en(synd_rd_en),
    .synd_rd_addr(synd_rd_addr),
    .error_loc_poly(error_loc_poly),
    .done(done)
  );
 
  wire [`m-1:0] synd_din;
  
  mem #(.WIDTH(`m), .DEPTH(2*`t), .FILE("data.in")) mem_synd (
    .clock (clk),
    .data (synd_din),
    .rdaddress (synd_rd_addr),
    .rden (synd_rd_en),
    .wraddress (0),
    .wren (1'b0),
    .q (synd_dout)
  );
  
  initial
    begin
      $dumpfile("BM_tb.vcd");
      $dumpvars(0, BM_tb);
    end
  
  integer scan_file;
 
  integer start_time;
  integer f;
  
  initial
    begin
      # 25;
      start_time = $time;
      start <= 1;
      
      # 10; 
      start <= 0;
      f = $fopen("data.out", "w");
      
      @(posedge done);
      $display("\n Total run time for BM: %0d cycles\n", ($time-start_time)/10);
      $fflush();
      
      $fwrite(f, "%b\n", DUT.error_loc_poly);
      $fflush();
      
      # 10;
      $fclose(f);
		
	  # 100;
      start_time = $time;
      start <= 1;
      
      # 10; 
      start <= 0;
      f = $fopen("data.out", "w");
      
      @(posedge done);
      $display("\n Total run time for BM: %0d cycles\n", ($time-start_time)/10);
      $fflush();
      
      $fwrite(f, "%b\n", DUT.error_loc_poly);
      $fflush();
      
      # 10;
      $fclose(f);
      
      # 10000;
      $finish;
    end
  
  always 
    #5 clk = ! clk; 
   
endmodule