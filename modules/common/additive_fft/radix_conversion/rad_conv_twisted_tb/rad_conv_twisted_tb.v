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


`timescale 1ns/1ps

module rad_conv_twisted_tb;
  //inputs
  reg                clk = 1'b0;
  reg                start = 1'b0;
  reg [`num*`gf-1:0] coeff_in = 0;
   
  //outputs
  wire [`num*`gf-1:0] coeff_out;
  wire 		            done;
  
  rad_conv_twisted DUT (
    .clk(clk),
    .start(start),
    .coeff_in(coeff_in),
    .coeff_out(coeff_out),
    .done(done)
  );

initial 
  begin
    $dumpfile("rad_conv_twisted.vcd");
	  $dumpvars(0, rad_conv_twisted_tb);
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
integer res_file;

initial
  begin
    res_file = $fopen("data_out.txt", "w");
    start <= 0;
    # 25;
    start <= 1;  
    start_time = $time;
    # 10;
    start <= 0;
    @(posedge done);
      $display("\nruntime: %0d cycles\n", ($time - start_time)/10);
    # 5;
    $fwrite(res_file, "%b\n", coeff_out);
    # 30;
    $fclose(res_file);
    # 1000;
    $finish;
  end

always 
  # 5 clk = ! clk;
  
endmodule

