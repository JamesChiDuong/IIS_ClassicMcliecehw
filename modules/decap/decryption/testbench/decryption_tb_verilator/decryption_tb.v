/*
 * This file is the testbench for decryption module.
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


// testbench for decryption module
`timescale 1ns/1ps

module decryption_tb
  (
    input  wire                        clk,
    input  wire                        start,
    output  wire                        done,
    output  wire                        decryption_fail
  );

  // inputs 
  reg [l-1:0] cipher = 0;
  reg [`m*(`t+1)-1:0] poly_g = 0;
  wire [`m-1:0] P_dout;

  // outputs
  wire [`N-1:0] error_recovered;
  wire P_rd_en;
  wire [`m-1:0] P_rd_addr;

  localparam l = `m*`t;

  decryption #(.m(`m), .t(`t), .N(`N), .BLOCK(`BLOCK), .mem_width(`mem_width), .mul_sec_BM(`mul_sec_BM), .mul_sec_BM_step(`mul_sec_BM_step)) DUT (
    .clk(clk),
    .start(start),
    .cipher(cipher),
    .poly_g(poly_g),
    .error_recovered(error_recovered),
    .done(done),
    .P_dout(P_dout),
    .P_rd_en(P_rd_en),
    .P_rd_addr(P_rd_addr),
    .decryption_fail(decryption_fail)
  );

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
  integer syndrome_time;
  integer BM_time;

  integer f;
 
   always @(posedge start)
   begin
      start_time <= $time;
 
   end

   always @(posedge done)
   begin
      f = $fopen("data.out","w");
      $fwrite(f, "%b\n", error_recovered); 
      $fclose(f); 

      $display("\n Total run time for decryption: %0d cycles\n", ($time-start_time));
      $display("\n%s", decryption_fail ? "Verification result:\n  re-encrypt fails!\n" : "Verification result:\n  re-encrypt succeeds.\n");
      
   end
		 
  always
      @(posedge DUT.syndrome_done)
    begin
      syndrome_time = $time;
      $display("----syndrome done");
    end

  always
      @(posedge DUT.BM_done)
    begin
      BM_time = $time;
      $display("----BM done");  
    end

  integer eva_time;
 
  always
      @(posedge DUT.eva_done)
    begin
      $display("----Eva done");
    end
   
endmodule

