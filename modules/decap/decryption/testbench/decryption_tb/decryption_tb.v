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

module decryption_tb;
  // inputs
  reg clk = 1'b0;
  reg start = 1'b0;
  reg [l-1:0] cipher = 0;
  reg [`m*(`t+1)-1:0] poly_g = 0;
  wire [`m-1:0] P_dout;

  // outputs
  wire [`N-1:0] error_recovered;
  wire done;
  wire P_rd_en;
  wire [`m-1:0] P_rd_addr;
  wire decryption_fail;

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

  initial
    begin
      $dumpfile("decryption_tb.vcd");
      $dumpvars(0, decryption_tb);
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
  integer syndrome_time;
  integer BM_time;

  integer f;

  initial
    begin
      # 25;
      start <= 1'b1;
      start_time <= $time;
      # 10;
      start <= 1'b0;

      f = $fopen("data.out","w");
      @(posedge done);
      $fwrite(f, "%b\n", error_recovered);
      $writememb("re_encryption_res.out", DUT.doubled_syndrome_inst.mem_synd_B.mem);
      $fclose(f);
      $fflush();

      $display("\nTotal run time for decryption: %0d cycles", ($time-start_time)/10);
       
      $display("\n%s", decryption_fail ? "Verification result:\n  re-encrypt fails!\n" : "Verification result:\n  re-encrypt succeeds.\n");
      
      $fflush();
		 
       # 1000;
      $finish;
    end

  always
    begin
      @(posedge DUT.syndrome_done);
      syndrome_time = $time;
      $display("----syndrome done");
      $fflush();
    end

  always
    begin
      @(posedge DUT.BM_done);
      BM_time = $time;
      $display("----BM done");
      $writememb("doubled_syndrome.out", DUT.doubled_syndrome_inst.mem_synd_A.mem);
      $fflush();
    end

  integer eva_time;

  always
    begin
      @(posedge DUT.eva_start);
      eva_time = $time;
      @(posedge DUT.eva_done);
      $display("----Eva done");
      $fflush();
    end
  

  always
	# 5 clk = !clk;

endmodule

