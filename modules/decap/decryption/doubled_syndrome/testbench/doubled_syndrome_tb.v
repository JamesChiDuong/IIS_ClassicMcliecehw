/*
 * This file is the testbench for doubled_syndrome module.
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

module doubled_syndrome_tb;
  
  // inputs
  reg clk = 1'b0;
  reg start = 1'b0;
  reg [l-1:0] cipher = 0;
  
  wire [`m-1:0] P_dout;
  reg [`CLOG2(2*`t)-1:0] synd_rd_addr_in = 0;
  wire [2*`m*`mem_width-1:0] eva_dout;
  
  // outputs
  wire P_rd_en;
  wire [`m-1:0] P_rd_addr;
  wire done;
  wire [`m-1:0] synd_dout_out;
  wire eva_rd_en;
  wire [`CLOG2(`t+1)-1:0] eva_rd_addr;
   
  reg [`m*(`t+1)-1:0] poly_g = 0;
  wire add_FFT_done;
  
  add_FFT #(.numc(`t+1), .gf(`m), .mem_width(`mem_width)) add_FFT_inst (
    .clk(clk),
    .start(start),
    .coeff_in(poly_g),
    .rd_en(eva_rd_en),
    .rd_addr(eva_rd_addr),
    .done(add_FFT_done),
    .data_out(eva_dout)
    
  );
  
  doubled_syndrome #(.m(`m), .t(`t), .N(`N), .mem_width(`mem_width)) DUT (
    .clk(clk),
    .operation(2'b01),
    .start(add_FFT_done),
    .cipher(cipher),
    .done(done),
    .synd_rd_en_in(1'b0),
    .synd_rd_addr_in(synd_rd_addr_in),
    .synd_A_dout_out(synd_dout_out),
    .re_encrypt_check_rd_en_in(0),
    .re_encrypt_check_rd_addr_in(0),
    .P_dout(P_dout),
    .P_rd_en(P_rd_en),
    .P_rd_addr(P_rd_addr),
    .P_rd_addr_re_encrypt(0),
    .eva_rd_en(eva_rd_en),
    .eva_rd_addr(eva_rd_addr),
    .eva_dout(eva_dout)
  );
  
  localparam l = `m*`t;
  
  // simulate dual-memory P
  wire [`m-1:0] dout;
  
  mem_dual #(.WIDTH(`m), .DEPTH(1 << `m), .FILE("P.in")) mem_dual_P (
    .clock(clk),
    .data_0(0), 
    .data_1(0),
    .address_0(P_rd_addr),
    .address_1(0),
    .wren_0(1'b0),
    .wren_1(1'b0),
    .q_0(P_dout),
    .q_1(dout)
  );
  
  initial
    begin
      $dumpfile("doubled_syndrome_tb.vcd");
      $dumpvars(0, doubled_syndrome_tb);
    end
  
  integer data_file_1;
  integer data_file_2;
  
  initial
    begin
      data_file_1 = $fopen("poly_g.in", "r");
      data_file_2 = $fopen("cipher.in", "r");
    end
  
  integer scan_file_1;
  integer scan_file_2;
  
  initial
    begin
      scan_file_1 = $fscanf(data_file_1, "%b\n", poly_g);
      scan_file_2 = $fscanf(data_file_2, "%b\n", cipher);
    end
  
  integer start_time;
    
  initial
    begin
      # 25;
      start <= 1'b1;
      start_time <= $time;
      # 10;
      start <= 1'b0;
      @(posedge add_FFT_done);
      $display("\n Evaulation done. Run time: %0d cycles\n", ($time-start_time)/10);
      $fflush();
      
      @(posedge DUT.done);
      $writememb("data.out", DUT.mem_synd_A.mem);
      $display("\n Total run time for doubled syndrome: %0d cycles\n", ($time-start_time)/10);
      $fflush();
	  
	  # 100;
      start <= 1'b1;
      start_time <= $time;
      # 10;
      start <= 1'b0;
      @(posedge add_FFT_done);
      $display("\n Evaulation done. Run time: %0d cycles\n", ($time-start_time)/10);
      $fflush();
      
      @(posedge DUT.done);
      $writememb("data.out", DUT.mem_synd_A.mem);
      $display("\n Total run time for doubled syndrome: %0d cycles\n", ($time-start_time)/10);
      $fflush();
      
      # 10000;      
      $finish;
    end
  
  always 
	# 5 clk = !clk;

endmodule
  
  
  
  
  
  
  
