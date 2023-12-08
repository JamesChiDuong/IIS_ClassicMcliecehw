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

  /* Generate clock signal */
  parameter CLK_PERIOD = 10; // simulation time
  parameter CLK_HALF_PERIOD = CLK_PERIOD/2;
  always #CLK_HALF_PERIOD clk=~clk;

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

  mem_dual #(.WIDTH(`m), .DEPTH(1 << `m), .FILE(`FILE_P)) mem_dual_P (
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

   /* read input data */
  initial
    begin
      data_file_1 = $fopen(`FILE_POLYG, "r");
      data_file_2 = $fopen(`FILE_CIPHER, "r");
    end

  integer scan_file_1;
  integer scan_file_2;

  initial
    begin
      scan_file_1 = $fscanf(data_file_1, "%b\n", poly_g);
      scan_file_2 = $fscanf(data_file_2, "%b\n", cipher);
    end

  integer f;

  initial
    begin
      // raise start signal for a single clock cycle
      # 25;
      start <= 1'b1;
      # CLK_PERIOD;
      start <= 1'b0;

      f = $fopen(`FILE_DATA_OUT,"w");
      @(posedge done);
      $fwrite(f, "%b\n", error_recovered);
      $writememb(`FILE_RE_ENC_OUT, DUT.doubled_syndrome_inst.mem_synd_B.mem);
      $fclose(f);
      $fflush();
      $display("\n%s", decryption_fail ? "Verification result:\n  re-encrypt fails!\n" : "Verification result:\n  re-encrypt succeeds.\n");

      $fflush();

       # 1000;
      $finish;
    end

   /* Waveform file */
   initial
     begin
        $dumpfile(`FILE_VCD);
        $dumpvars(0, decryption_tb);
     end

   /* Clock cycle count profiling */
   integer f_cycles_profile;
   time time_decryption_start;
   time time_add_fft_start;
   time time_doubled_syndrome_start;
   time time_bm_start;
   time time_error_loc_start;
   reg [17*8-1:0] prefix;

   initial
     begin
        f_cycles_profile = $fopen(`FILE_CYCLES_PROFILE,"w");
        $sformat(prefix, "[mceliece%0d%0d]", DUT.N, DUT.t);
     end

   /* Total time of decryption module */
   always
     begin
        @(posedge DUT.start);
        time_decryption_start = $time;
        $display("%s Decryption module started.", prefix);
        $fflush();
     end

   always
     begin
        @(posedge DUT.done);
        $display("%s Decryption module finished. (%0d cycles)", prefix, ($time-time_decryption_start)/CLK_PERIOD);
        $fwrite(f_cycles_profile, "total %0d %0d\n", time_decryption_start/CLK_PERIOD, ($time-time_decryption_start)/CLK_PERIOD);
        $fflush();
     end

   /* Additive FFT module */
   always
     begin
        @(posedge DUT.add_FFT_synd_inst.start);
        time_add_fft_start = $time;
        $display("%s Additive FFT module started.", prefix);
        $fflush();
     end

   always
     begin
        @(posedge DUT.add_FFT_synd_inst.done);
        $display("%s Additive FFT module finished. (%0d cycles)", prefix, ($time-time_add_fft_start)/CLK_PERIOD);
        $fwrite(f_cycles_profile, "add_fft %0d %0d\n", time_add_fft_start/CLK_PERIOD, ($time-time_add_fft_start)/CLK_PERIOD);
        $fflush();
     end

   /* Doubled syndrome module */
   always
     begin
        @(posedge DUT.doubled_syndrome_inst.start);
        time_doubled_syndrome_start = $time;
        $display("%s Doubled syndrome module started.", prefix);
        $fflush();
     end

   always
     begin
        @(posedge DUT.doubled_syndrome_inst.done);
        $display("%s Doubled syndrome module finished. (%0d cycles)", prefix, ($time-time_doubled_syndrome_start)/CLK_PERIOD);
        $fwrite(f_cycles_profile, "doubled_syndrome %0d %0d\n", time_doubled_syndrome_start/CLK_PERIOD, ($time-time_doubled_syndrome_start)/CLK_PERIOD);
        $fflush();
     end

   /* Berlekamp Massey decoder module */
   always
     begin
        @(posedge DUT.BM_inst.start);
        time_bm_start = $time;
        $display("%s Berlekamp Massey decoder module started.", prefix);
        $fflush();
     end

   always
     begin
        @(posedge DUT.BM_inst.done);
        $display("%s Berlekamp Massey decoder module finished. (%0d cycles)", prefix, ($time-time_bm_start)/CLK_PERIOD);
        $fwrite(f_cycles_profile, "bm %0d %0d\n", time_bm_start/CLK_PERIOD, ($time-time_bm_start)/CLK_PERIOD);
        $fflush();
     end

   /* Error locator module */
   always
     begin
        @(posedge DUT.error_loc_inst.start);
        time_error_loc_start = $time;
        $display("%s Error locator module started.", prefix);
        $fflush();
     end

   always
     begin
        @(posedge DUT.error_loc_inst.done);
        $display("%s Error locator module finished. (%0d cycles)", prefix, ($time-time_error_loc_start)/CLK_PERIOD);
        $fwrite(f_cycles_profile, "error_loc %0d %0d\n", time_error_loc_start/CLK_PERIOD, ($time-time_error_loc_start)/CLK_PERIOD);
        $fflush();
     end
endmodule

