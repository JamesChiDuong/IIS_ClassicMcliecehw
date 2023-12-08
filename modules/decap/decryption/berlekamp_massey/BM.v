/*
 * This file is the Berlekamp-Massey module.
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


module BM
#(
  parameter m = 13,
  parameter t = 119,
  parameter mul_sec_BM = 20, // number of multipliers inside vec_mul_multi in BM module
  parameter mul_sec_BM_step = 10 // number of multipliers inside vec_mul_multi in BM module
)
(
  input wire clk,
  input wire start,
  input wire [m-1:0] synd_dout,

  output wire synd_rd_en,
  output wire [`CLOG2(2*t)-1:0] synd_rd_addr,

  output wire [m*(t+1)-1:0] error_loc_poly,
  output wire done
);

  localparam t_mul_ceil = mul_sec_BM*((t+mul_sec_BM)/mul_sec_BM);

  wire step_done;

  assign synd_rd_en = start | step_done;
  reg dout_valid = 1'b0;

  reg [`CLOG2(2*t)-1:0] synd_rd_addr_out = {`CLOG2(2*t){1'b0}};
  assign synd_rd_addr = synd_rd_addr_out;

  reg mul_start_buffer = 1'b0;
  reg mul_start = 1'b0;
  reg [m*(t+1)-1:0] syndrome_t = {m*(t+1){1'b0}}; // d = sum(sigma_x, syndrome_t)

  wire [m*t_mul_ceil-1:0] d_vec;
  wire mul_done;

  wire [m-1:0] d_sum;
  reg [m-1:0] d_sum_reg = {m{1'b0}};

  reg step_start = 1'b0;

  wire [m*(t+1)-1:0] sigma_x; // = {m*(t+1){1'b0}}; // sigma(x) = 1
  reg [`CLOG2(2*t+1)-1:0] l_int = {(`CLOG2(2*t+1)){1'b0}}; // integer
  reg [m-1:0] delta_gf = {m{1'b0}}; // field element
  reg [`CLOG2(2*t+1)-1:0] k_int = {`CLOG2(2*t+1){1'b0}}; // round counter

  wire [`CLOG2(2*t+1)-1:0] l_out;
  wire [m-1:0] delta_out;

  reg done_buffer = 1'b0;

  reg running = 1'b0;

  always @(posedge clk)
    begin

      running <= start ? 1'b1 :
                 done ? 1'b0 :
                 running;

      synd_rd_addr_out <= synd_rd_en ? synd_rd_addr_out + 1 :
                          done ? {`CLOG2(2*t){1'b0}} :
                          synd_rd_addr_out;
 
      dout_valid <= synd_rd_en;

      syndrome_t <= (start | done) ? {m*(t+1){1'b0}} :
                    dout_valid ? (syndrome_t << m) ^ {{m*t{1'b0}}, synd_dout} :
                    syndrome_t;

      mul_start_buffer <= (start | (running & step_done & k_int < (2*t-1)));
      mul_start <= mul_start_buffer;

      d_sum_reg <= d_sum;

      step_start <= running && mul_done;

      l_int <= start ? {(`CLOG2(2*t+1)){1'b0}} :
               step_done ? l_out :
               l_int;

      delta_gf <= start ? {{(m-1){1'b0}}, 1'b1} :
                  step_done ? delta_out :
                  delta_gf;

      k_int <= start ? {`CLOG2(2*t+1){1'b0}} :
               step_done ? k_int + 1 :
               k_int;

      done_buffer <= (step_done && (k_int == (2*t-1))); // need to be checked here

    end

  assign done = done_buffer;

//  assign error_loc_poly = sigma_x;
  genvar i;
  generate
    for (i = 1; i <= (t+1); i = i+1)
      begin: gen_err_loc
        assign error_loc_poly[m*i-1:(i-1)*m] = sigma_x[(t+1-i)*m+m-1:(t+1-i)*m];
      end
  endgenerate

  vec_mul_multi_BM vec_mul_multi_BM_inst (
    .clk(clk),
    .start(mul_start),
    .vec_a({{m*(t_mul_ceil-(t+1)){1'b0}}, sigma_x}),
    .vec_b({{m*(t_mul_ceil-(t+1)){1'b0}}, syndrome_t}),
    .vec_c(d_vec),
    .done(mul_done)
  );

  entry_sum entry_sum_inst (
    .clk(clk),
    .vector(d_vec[m*(t+1)-1:0]),
    .sum(d_sum)
  );

  BM_step #(.t(t), .N(mul_sec_BM_step), .m(m)) BM_step_inst (
    .clk(clk),
    .start(step_start),
    .init(start),
    .d_in(d_sum_reg),
    .l_in(l_int),
    .delta_in(delta_gf),
    .k_in(k_int),
    .sigma_out(sigma_x),
    .l_out(l_out),
    .delta_out(delta_out),
    .done(step_done)
  );
 
endmodule

