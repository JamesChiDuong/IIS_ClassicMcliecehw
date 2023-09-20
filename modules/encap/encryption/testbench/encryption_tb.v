/*
 * 
 *
 * Copyright (C) 2021
 * Author: Sanjay Deshpande <sanjay.deshpande@yale.edu>
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

module encrypt_col_block_128_tb
  #(
    parameter parameter_set =2,
    
    
    parameter n = (parameter_set == 1)? 3488:
                  (parameter_set == 2)? 4608:
                  (parameter_set == 3)? 6688:
                  (parameter_set == 4)? 6960: 
                                        8192,
                                         
    parameter m = (parameter_set == 1)? 12:13,    
    
    parameter t = (parameter_set == 1)? 64:
                  (parameter_set == 2)? 96:
                  (parameter_set == 3)? 128:
                  (parameter_set == 4)? 119: 
                                        128,
   
   parameter col_width = 128,
   parameter k = n-m*t,
//   parameter l = m*t + (32-(m*t)%32)%32, //m*t,
   parameter l = m*t,
   parameter e_width = 128, // error_width
   parameter k_b_width = 32 //key column block width
                                        
                                        
                                      
  );

// input  
reg clk = 1'b0;
reg rst = 1'b0;
reg start = 1'b0;
reg K_col_valid = 1'b0;
wire [col_width -1:0] K_col;

// output
wire done;
wire K_ready;
wire e_ready;
wire [32 -1:0]cipher;

//ram controls
reg [2:0] addr;
wire [e_width-1:0] error;

//reg [`CLOG2(((n+(n%e_width))/e_width)) - 1:0] addr_e;
//wire [`CLOG2(((n+(n%e_width))/e_width)) - 1:0] addr_e;
wire [`CLOG2(((l + (e_width-l%e_width)%e_width) + (k + (e_width-(k)%e_width)%e_width))/e_width) - 1:0] addr_e;
//reg [`CLOG2(l*k/col_width) - 1:0] addr_h;
reg [`CLOG2((k+(col_width-k%col_width)%col_width)*l/col_width) - 1:0] addr_h;

reg [`CLOG2(l/col_width) - 1:0] addr_rd_c = 0;
reg rd_en_c = 0;

parameter wait_time = (((n+(n%e_width))/e_width) + 2)*10;

     
  encrypt_col_block # (.parameter_set(parameter_set), .m(m), .t(t), .n(n), .l(l), .e_width(e_width), .col_width(col_width))
  DUT  (
    .clk(clk),
    .rst(rst),
    .start(start),
    .e_addr(addr_e),
    .K_col_valid(K_col_valid),
    .error(error),
    .K_col(K_col),
    .K_ready(K_ready),
    .done(done),
    .addr_rd_c(addr_rd_c),
    .rd_en_c(rd_en_c),
    .cipher(cipher)
    );
  

  integer start_time;
  
  
  initial
    begin
    rst <= 1'b1;
    addr_h = 0;
    # 20;
    rst <= 1'b0;
    #100
    start_time = $time;
    
    start = 1'b1;
    #10
    start = 1'b0;
    
    @(posedge K_ready);

    
//    for (integer j=0; j <= (k*l/col_width)-1; j = j+1) begin
    for (integer j=0; j <= ((k+(col_width-k%col_width)%col_width)*l/col_width)-1; j = j+1) begin
      #10; addr_h <= addr_h + 1; K_col_valid <= 1'b1; 
    end
    
    
      @(posedge done);
      K_col_valid = 1'b0;
      # 10000;
      $finish;
    end
  
//  integer f;
//  // output file to see the positions where weight is added
//  always 
//    begin
//      f = $fopen("output.txt","w");
//      @(posedge done);
//         for (integer k = 0; k<l; k=k+1) begin
//            $fwrite(f,"%b",cipher[l-k-1]);
//         end 
//    end
    
  integer f;
   // output file to see the final ciphertext
    always 
    begin
      @(posedge DUT.done);
      case (parameter_set)
      
        1: begin
            $writememb("output_sliced_1.out", DUT.encrypt_mem.mem);
            $fflush();
           end
        
        2: begin
            $writememb("output_sliced_2.out", DUT.encrypt_mem.mem);
            $fflush();
           end

        3: begin
            $writememb("output_sliced_3.out", DUT.encrypt_mem.mem);
            $fflush();
           end

        4: begin
            $writememb("output_sliced_4.out", DUT.encrypt_mem.mem);
            $fflush();
           end

        5: begin
            $writememb("output_sliced_5.out", DUT.encrypt_mem.mem);
            $fflush();
           end

           
      default:  begin
            $writememb("output_sliced_1.out", DUT.encrypt_mem.mem);
            $fflush();
           end
      endcase
    end    
    

         
  
always 
  # 5 clk = !clk;

parameter e_file =  (parameter_set == 1)? "error_1_128.in":
                    (parameter_set == 2)? "error_2_128.in":
                    (parameter_set == 3)? "error_3_128.in":
                    (parameter_set == 4)? "error_4_128.in": 
                                          "error_5_128.in";
  

parameter H_sliced = (parameter_set == 1)? "pub_sliced_1_128.in":
                     (parameter_set == 2)? "pub_sliced_2_128.in":
                     (parameter_set == 3)? "pub_sliced_3_128.in":
                     (parameter_set == 4)? "pub_sliced_4_128.in": 
                                           "pub_sliced_5_128.in";                                         




 mem_single #(.WIDTH(e_width), .DEPTH(((n+(e_width -n%e_width)%e_width)/e_width)), .FILE(e_file) ) errorvector
 (
        .clock(clk),
        .data(0),
        .address(addr_e),
        .wr_en(0),
        .q(error)
 );  

// mem_single #(.WIDTH(l), .DEPTH(n), .FILE(H_file) ) publickey
// mem_single #(.WIDTH(col_width), .DEPTH(k*l/col_width), .FILE(H_sliced) ) publickey
// mem_single #(.WIDTH(col_width), .DEPTH((k+(col_width-k%col_width)%col_width)*l/col_width), .FILE(H_sliced) ) publickey
 mem_single #(.WIDTH(col_width), .DEPTH((k+(col_width-k%col_width)%col_width)*l/col_width), .FILE(H_sliced) ) publickey
 (
        .clock(clk),
        .data(0),
        .address(addr_h),
        .wr_en(0),
        .q(K_col)
 );
   
endmodule

  
  
  
  
  
  
  