/*
 * This file is testbench for BM_step module.
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


// one iteration within BM algorithm

module BM_step
#(
  parameter t = 119,
  parameter N = 20, // number of multipliers needed
  parameter m = 13
)
( 
  input wire clk,
  input wire start,
  input wire init,
  input wire [m-1:0] d_in,
  
  input wire [`CLOG2(2*t+1)-1:0] l_in, // integer
  input wire [m-1:0] delta_in,
  input wire [`CLOG2(2*t+1)-1:0] k_in,
  
  output wire [m*(t+1)-1:0] sigma_out,
  output wire [`CLOG2(2*t+1)-1:0] l_out,
  output wire [m-1:0] delta_out,
  
  output wire done
);
  
 
  localparam t_ceil = N*((t+N)/N);
  
  reg condition_1 = 1'b0; // d = 0 or k < 2l
  
  reg [m*(t+1)-1:0] sigma_x = {m*(t+1){1'b0}};
  reg [`CLOG2(2*t+1)-1:0] l_out_buffer = {(`CLOG2(2*t+1)){1'b0}};
  reg [m-1:0] delta_out_buffer = {m{1'b0}};
  
  reg start_buffer = 1'b0;
  reg mul_start = 1'b0;
  
  wire [m-1:0] delta_inv;
 
  wire inv_dout_en;
  wire [m-1:0] d_over_delta;
  reg [m-1:0] d_over_delta_buffer = {m{1'b0}};
  
  wire [m*(t+1)-1:0] vec_a;
  wire [m*t_ceil-1:0] vec_c;
  wire mul_done;

  reg [m*(t+1)-1:0] beta_x;
  
  genvar i;
  generate
    for (i = 1; i <= (t+1); i = i+1)
      begin: gen_vec_a
        assign vec_a[m*i-1:(i-1)*m] = d_over_delta_buffer;
      end
  endgenerate
   
  always @(posedge clk)
    begin
		
     d_over_delta_buffer <= d_over_delta;
      
      condition_1 <= ((d_in == {m{1'b0}}) | (k_in < (l_in << 1)));
      
      start_buffer <= start;
      
      mul_start <= start_buffer;
           
      sigma_x  <= init ? {{(m*(t+1)-1){1'b0}}, 1'b1} :
                   mul_done ? sigma_x ^ vec_c[m*(t+1)-1:0]:
                   sigma_x;
     
      beta_x <= init ? {{(m*t-1){1'b0}}, 1'b1, {m{1'b0}}} : 
                 mul_done ? (condition_1 ? (beta_x << m) : (sigma_x << m)):
                 beta_x;
     
      l_out_buffer <= condition_1 ? l_in : (k_in-l_in+1);
      
      delta_out_buffer <= condition_1 ? delta_in : d_in;

    end
  
  assign sigma_out = sigma_x;
  assign l_out = l_out_buffer;
  assign delta_out = delta_out_buffer;
  assign done = mul_done;
  
  wire [m-1:0] dout_B;
  wire dout_en_B;
   
//  delta^-1
GFE_inv_BM_step  #(.DELAY(1)) GFE_inv_BM_step_inst (
  .clk(clk),
  .din_A(delta_in),
  .dout_A(delta_inv),
  .dout_en_A(inv_dout_en),
  .din_B(0),
  .dout_B(dout_B),
  .dout_en_B(dout_en_B)
);
  
  // d*delta^-1
gf_mul gf_mul_BM_inst (
  .clk(clk),
  .dinA(delta_inv),
  .dinB(d_in),
  .dout(d_over_delta)
);

  //(d*delta^-1)*beta(x)
vec_mul_multi_BM_step vec_mul_multi_BM_step_inst (
  .clk(clk),
  .start(mul_start),
  .vec_a({{(t_ceil-(t+1))*m{1'b0}}, vec_a}),
  .vec_b({{(t_ceil-(t+1))*m{1'b0}}, beta_x}),
  .vec_c(vec_c),
  .done(mul_done)
);
  
endmodule

