/*
 * This file is the testbench for the gen_support module.
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

module gen_support_tb;
  
  // inputs
  reg clk = 1'b0;
  reg start = 1'b0;
  
  reg rd_en = 1'b0;
  reg [`M-1:0] rd_addr = 0;
  
  // outputs
  wire done;
  wire [`M-1:0] index_out;
  wire [`SIGMA2-1:0] rand_dout;

  reg wr_en;
  reg [`M-1:0] wr_addr;
  reg [`SIGMA2-1:0] rand_in;
  
  gen_support #(.M(`M), .SIGMA2(`SIGMA2)) DUT (
    .clk(clk),
    .wr_en(wr_en),  
    .wr_addr(wr_addr),
    .rand_in(rand_in),
    .start(start),
    .done(done),
    .index_out(index_out),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .rand_dout(rand_dout)
  );
 
  //initial
  //  begin
  //    $dumpfile("gen_support_tb.vcd");
  //    $dumpvars(0, gen_support_tb);
  //  end
  
  integer data_file, scan_file;
    
  integer start_time;
  integer init_time;
  
  integer f1;
  integer f2;
  
  integer points;

  integer data;
  
  initial
    begin
      wr_addr <= 0;
      wr_en <= 0;
      rand_in <= 0;
      start <= 0;
      # 45;

      # 10;
      data_file = $fopen("sage_rand.out", "r");
      # 10;
      start_time = $time;
      wr_en <= 1;
      while (!$feof(data_file)) begin
         scan_file = $fscanf(data_file, "%b\n", data);
         rand_in <= data;
         # 10;
         wr_addr <= wr_addr + 1;
      end
      wr_en <= 0;
      init_time = $time;

      start <= 1;
      # 10;
      start <= 0;
      $display("\n runtime for initialization: %0d cycles\n", (init_time-start_time)/10);
      $fflush();

      @(posedge DUT.done);

      $display("\n runtime for gen_support: %0d cycles\n", (($time-init_time)/10));
      $display("\n total runtime for gen_support(init+gen_support): %0d cycles\n", (($time-start_time)/10));
      $fflush();
      
      # 105;
      f1 = $fopen("sorted.out", "w");
      f2 = $fopen("perm.out", "w");


      rd_en <= 1'b1;
      rd_addr <= 0;

      points = 0;

      for (points = 0; points < (1 << `M); points = points + 1)
        begin
          # 10;
          $fwrite(f1, "%b\n", rand_dout);
          $fflush();
          $fwrite(f2, "%b\n", index_out);
          $fflush();
          rd_addr <= rd_addr + 1;
        end
      rd_en <= 1'b0;
      # 100;
      $fclose(f1);
      $fclose(f2);
      $finish;
               
    end
               
  always 
    # 5 clk = !clk;
               
endmodule
               
  
  
