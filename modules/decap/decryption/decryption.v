/*
 * This file is the decryption module.
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



/**************

input: length m*t ciphertext c, SK: g(x) and length n*m P
output: error vector e

Steps:
1: calculate doubled syndrome S = H_2*P*[c|0]
2: error locator polynomial sigma(x) = BM(S)
3: error locating: e = add_FFT(sigma(x))

***************/

module decryption
  #(
    parameter m = 13,   // 2^m is the size of the finite field, m=13
    parameter t = 119,  // number of errors
    parameter N = 6960, // code length
    parameter BLOCK = 100, // block size in syndrome module
    parameter mem_width = 32, // memory width in add_FFT (mem_A/B)
    parameter mul_sec_BM = 20, // number of multipliers inside vec_mul_multi in BM module
    parameter mul_sec_BM_step = 10, // number of multipliers inside vec_mul_multi in BM module

    parameter l = m*t,
    parameter eva_mem_WIDTH = 2*m*mem_width, //memory width in the add_FFT module, sum of mem_A and mem_B
    parameter eva_mem_WIDTH_bits = `CLOG2(mem_width)+1,
    parameter eva_mem_DEPTH = (1 << (`CLOG2(t+1))), //memory depth in the add_FFT module
    parameter eva_mem_DEPTH_bits = `CLOG2(t+1)

  )
  (
    input wire 					   clk,
    input wire 					   start,
    input wire [l-1:0] 			   cipher, // ciphertext
    input wire [m*(t+1)-1:0] 	   poly_g, // Goppa polynomial g(x)
    output reg [N-1:0] 			   error_recovered = {N{1'b0}},
    output reg 					   done = 1'b0,

    // memory interface of P, assume part of the SK is stored in a m*n P memory
    input wire [m-1:0] 			   P_dout,
    output wire 				   P_rd_en,
    output wire [m-1:0] 		   P_rd_addr,

`ifdef SHARED
   //shared ADD FFT ports
	output wire 				   fft_eva_start_dec,
	output wire [m*(t+1)-1:0] 	   fft_coeff_in_dec,
	output wire 				   fft_rd_en_dec,
	output wire [`CLOG2(t+1)-1:0]  fft_rd_addr_dec,
	input wire [eva_mem_WIDTH-1:0] fft_eva_dout_dec,
	input wire 					   fft_eva_done_dec,
`endif
    output reg 					   decryption_fail = 1'b0 // decryption can fail, will report a bit 1 if this happens
  );
  
  wire [eva_mem_WIDTH-1:0] eva_dout;
  wire eva_done;
  
  wire synd_rd_en_in;
  wire [`CLOG2(2*t)-1:0] synd_rd_addr_in;
  wire [m-1:0] synd_A_dout_out;

  reg re_encrypt_check_rd_en_in = 1'b0;
  reg [`CLOG2(2*t)-1:0] re_encrypt_check_rd_addr_in = {`CLOG2(2*t){1'b0}};
  wire [m-1:0] synd_B_dout_out;

  wire syndrome_done;

  wire [m*(t+1)-1:0] error_loc_poly;

  wire err_eva_rd_en;
  wire [`CLOG2(t+1)-1:0] err_eva_rd_addr;

  wire BM_done;

  wire P_rd_en_syndrome;
  wire [m-1:0] P_rd_addr_syndrome;

  wire P_rd_en_error_loc;
  wire [m-1:0] P_rd_addr_error_loc; 

  wire syn_eva_rd_en;
  wire [eva_mem_DEPTH_bits-1:0] syn_eva_rd_addr;
 
  reg syndrome_running = 1'b0;
  
  wire error_loc_done;
   
  wire [N-1:0] error_recovered_out; 

  wire eva_start;
  
  reg [1:0] syndrome_operation = 2'b00; 

  wire [m*t-1:0] P_rd_addr_re_encrypt;
  
  reg [1:0] eva_counter = 2'b00;
  
  wire comp_syndrome_start;
  wire comp_syndrome_done;

  wire re_encryption_start;
  wire re_encryption_done;

  reg re_encryption_check_running = 1'b0;
  reg done_buf = 1'b0;
 
  wire syndrome_start;

  wire error_loc_start;
  
  // decryption fails if: the hamming weight of the recovered error != t
  wire decryption_fail_hamming_weight_mismatch;
  //                  or: the re-encryption fails
  wire decryption_fail_re_encryption_fails;

  wire [`CLOG2(t):0] error_hamming_weight;

  assign P_rd_en = P_rd_en_syndrome | P_rd_en_error_loc;
  assign P_rd_addr = P_rd_en_syndrome ? P_rd_addr_syndrome : P_rd_addr_error_loc;
  
  assign comp_syndrome_start = (eva_counter == 2'b00) & eva_done;
  assign error_loc_start = (eva_counter == 2'b01) & eva_done;
  assign re_encryption_start = (eva_counter == 2'b10) & eva_done;

  assign syndrome_start = comp_syndrome_start | re_encryption_start;

  assign comp_syndrome_done = syndrome_done & (syndrome_operation == 2'b01);
  assign re_encryption_done = syndrome_done & (syndrome_operation == 2'b10);

  assign eva_start = start | BM_done | error_loc_done;

  assign decryption_fail_hamming_weight_mismatch = error_loc_done & (error_hamming_weight != t);
  assign decryption_fail_re_encryption_fails = re_encryption_check_running & (synd_A_dout_out != synd_B_dout_out);
  
  always @(posedge clk)
    begin
  	  done_buf <= (re_encrypt_check_rd_addr_in == (2*t-1));
      done <= done_buf;

      re_encryption_check_running <= start | done ? 1'b0 :
                                     re_encryption_done ? 1'b1 :
                                     re_encryption_check_running;

  	  error_recovered <= error_loc_done ? error_recovered_out : error_recovered;
  	 
      eva_counter <= start | done ? 2'b00 :
                     eva_done ? eva_counter + 1 :
                     eva_counter;
   
      syndrome_running  <= syndrome_start ? 1'b1 :
                           start | syndrome_done | done ? 1'b0 :
                           syndrome_running;

      syndrome_operation <= (start | comp_syndrome_done | re_encryption_done) ? 2'b00 :
                            comp_syndrome_start ? 2'b01 :
                            re_encryption_start ? 2'b10 :
                            syndrome_operation;
      
      // check the result of re-encryption by comparing the contents of two memories
      re_encrypt_check_rd_en_in <= start | (re_encrypt_check_rd_addr_in == (2*t-1)) ? 1'b0 : 
                                   re_encryption_done ? 1'b1 :
                                   re_encrypt_check_rd_en_in;

      re_encrypt_check_rd_addr_in <= start ? {`CLOG2(2*t){1'b0}} :
                                     re_encrypt_check_rd_en_in ? re_encrypt_check_rd_addr_in + 1 :
                                     re_encrypt_check_rd_addr_in;
      
      decryption_fail <= start ? 1'b0 :
                         decryption_fail_hamming_weight_mismatch | decryption_fail_re_encryption_fails ? 1'b1 :
                         decryption_fail;
  end

  
`ifndef SHARED
  add_FFT #(.numc(t+1), .gf(m), .mem_width(mem_width)) add_FFT_synd_inst (
    .clk(clk),
    .start(eva_start),
    // coeff input
    .coeff_in(BM_done ? error_loc_poly : poly_g),
    // add_FFT output
    .rd_en(syndrome_running ? syn_eva_rd_en : err_eva_rd_en),
    .rd_addr(syndrome_running ? syn_eva_rd_addr : err_eva_rd_addr),
    .data_out(eva_dout),
    //
    .done(eva_done)
  );
`endif

`ifdef SHARED
   assign fft_eva_start_dec  = eva_start;
   assign fft_coeff_in_dec = BM_done ? error_loc_poly : poly_g;
   assign fft_rd_en_dec = syndrome_running ? syn_eva_rd_en : err_eva_rd_en;
   assign fft_rd_addr_dec = syndrome_running ? syn_eva_rd_addr : err_eva_rd_addr;
   assign eva_dout = fft_eva_dout_dec;
   assign eva_done = fft_eva_done_dec;
`endif

  doubled_syndrome #(.m(m), .t(t), .N(BLOCK), .mem_width(mem_width)) doubled_syndrome_inst (
    .clk(clk),
    .start(syndrome_start),
    .cipher(cipher),
    .done(syndrome_done),
    // syndrome output
    .synd_rd_en_in(synd_rd_en_in),
    .synd_rd_addr_in(synd_rd_addr_in),
    .synd_A_dout_out(synd_A_dout_out),
    // result holding re-encryption result
    .re_encrypt_check_rd_en_in(re_encrypt_check_rd_en_in),
    .re_encrypt_check_rd_addr_in(re_encrypt_check_rd_addr_in),
    .synd_B_dout_out(synd_B_dout_out),
    // P inout
    .P_dout(P_dout),
    .P_rd_en(P_rd_en_syndrome),
    .P_rd_addr(P_rd_addr_syndrome),
    // poly eval input
    .eva_rd_en(syn_eva_rd_en),
    .eva_rd_addr(syn_eva_rd_addr),
    .eva_dout(eva_dout), 
    .operation(syndrome_operation),
    .P_rd_addr_re_encrypt(P_rd_addr_re_encrypt)
  );

  BM #(.m(m), .t(t), .mul_sec_BM(mul_sec_BM), .mul_sec_BM_step(mul_sec_BM_step)) BM_inst (
    .clk(clk),
    .start(comp_syndrome_done),
    // syndrome input
    .synd_dout(synd_A_dout_out),
    .synd_rd_en(synd_rd_en_in),
    .synd_rd_addr(synd_rd_addr_in),
    // BM output
    .error_loc_poly(error_loc_poly),
    .done(BM_done)
  );


  error_locator #(.m(m), .n(N), .t(t)) error_loc_inst (
    .clk(clk),
    .start(error_loc_start),
    // error_loc output
    .error_recovered(error_recovered_out),
    .done(error_loc_done),
    // poly eval input
    .eva_dout(eva_dout),
    .eva_rd_en(err_eva_rd_en),
    .eva_rd_addr(err_eva_rd_addr),
    // P input
    .P_dout(P_dout),
    .P_rd_en(P_rd_en_error_loc),
    .P_rd_addr(P_rd_addr_error_loc),
    .P_rd_addr_re_encrypt(P_rd_addr_re_encrypt),
    .error_hamming_weight(error_hamming_weight)
  );

endmodule

