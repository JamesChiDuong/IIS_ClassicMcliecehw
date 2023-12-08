/*
 * This file is the testbench for the poly_mul_reduced module.
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

module poly_mul_reduced_tb;
  //input
  reg 		  start = 0;
  reg 		  clk = 0;
   
  reg [`gf*`t-1:0] poly_g = 0;
  reg [`gf*`t-1:0] poly_f = 0;
   
  //output
  wire [`gf*`t-1:0] poly_out;
  wire		               done;
//  wire                 poly_mul_20_done;
  
  poly_mul_reduced DUT (
    .start(start),
    .clk(clk),
    .poly_g(poly_g),
    .poly_f(poly_f),
    .poly_out(poly_out),
    .done(done)
//    .poly_mul_20_done(poly_mul_20_done)
  );
 
 integer STDERR = 32'h8000_0002;
 integer STDIN  = 32'h8000_0000;
  
 initial 
  begin
    $dumpfile("poly_mul_reduced_tb.vcd");
    $dumpvars(0, poly_mul_reduced_tb);
  end

 
integer scan_file;

initial
  begin
    scan_file = $fscanf(STDIN, "%b\n", poly_g);
    scan_file = $fscanf(STDIN, "%b\n", poly_f);
  end  

integer start_time;
 
initial
  begin
   # 25;
   start <= 1'b1;
   start_time <= $time;
   # 10;
   start <= 1'b0;  
    /*
   @(posedge poly_mul_20_done);
   $display("poly_mul_20 is done");
   */
   @(posedge done);
	 $fdisplay(STDERR,"\nruntime: %0d cycles\n", ($time - start_time)/10); 
   $write("%b\n", poly_out); 	
   # 50;
   $finish;
   
  end

always 
	# 5 clk = !clk;

endmodule

