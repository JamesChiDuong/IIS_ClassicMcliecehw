'''
 * This file generates the top level main module.
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
'''


import sys

import argparse

parser = argparse.ArgumentParser(description='Generate toplevel main module.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-m', '--gf', dest='m', type=int, default=13,
          help='field GF(2^m); default = GF(2^13)')
parser.add_argument('-t', '--t', dest='t', type=int, default=119,
          help='number of errors')
parser.add_argument('-N', dest='N', type=int, required= True,
          help='code length')
parser.add_argument('-BLOCK', dest='BLOCK', type=int, required=False, default=-1,
          help='block size in syndrome module')
parser.add_argument('-mem_width', dest='mem_width', type=int, required= True,
          help='memory width in add_FFT (mem_A/B)')
parser.add_argument('-mul_sec_BM', dest='mul_sec_BM', type=int, required=False, default=-1,
          help='number of multipliers inside vec_mul_multi in BM module')
parser.add_argument('-mul_sec_BM_step', dest='mul_sec_BM_step', type=int, required= True,
          help='number of multipliers inside vec_mul_multi in BM module')
 
args = parser.parse_args()

m = args.m

t = args.t

N = args.N

BLOCK = args.BLOCK

mem_width = args.mem_width

mul_sec_BM = args.mul_sec_BM

mul_sec_BM_step = args.mul_sec_BM_step

print("""module main
  #(
    parameter m = {m},   // 2^m is the size of the finite field, m=13
    parameter t = {t},  // number of errors
    parameter N = {N}, // code length
    parameter BLOCK = {BLOCK}, // block size in syndrome module
    parameter mem_width = {mem_width}, // memory width in add_FFT (mem_A/B)
    parameter mul_sec_BM = {mul_sec_BM}, // number of multipliers inside vec_mul_multi in BM module
    parameter mul_sec_BM_step = {mul_sec_BM_step}, // number of multipliers inside vec_mul_multi in BM module

    parameter l = m*t,
    parameter eva_mem_WIDTH = 2*m*mem_width, //memory width in the add_FFT module, sum of mem_A and mem_B
    parameter eva_mem_WIDTH_bits = `CLOG2(mem_width)+1,
    parameter eva_mem_DEPTH = (1 << (`CLOG2(t))), //memory depth in the add_FFT module
    parameter eva_mem_DEPTH_bits = `CLOG2(t) 
  )
  (
    (*S="TRUE"*) input wire                        clk,
    (*S="TRUE"*) input wire                        start,
    (*S="TRUE"*) input wire  [l-1:0]               cipher, // ciphertext
    (*S="TRUE"*) input wire  [m*(t+1)-1:0]         poly_g, // Goppa polynomial g(x)
    (*S="TRUE"*) output wire [N-1:0]               error_recovered,
    (*S="TRUE"*) output                            done,
    (*S="TRUE"*) output                            decryption_fail,
`ifdef SHARED
       //shared ADD FFT ports 
   (*S="TRUE"*) output wire fft_eva_start_dec,
   (*S="TRUE"*) output wire [m*(t+1)-1:0] fft_coeff_in_dec,
   (*S="TRUE"*) output wire fft_rd_en_dec,
   (*S="TRUE"*) output wire [`CLOG2(t+1)-1:0] fft_rd_addr_dec,
   (*S="TRUE"*) input  wire [eva_mem_WIDTH-1:0] fft_eva_dout_dec,
   (*S="TRUE"*) input  wire fft_eva_done_dec,
`endif
    // memory interface of P, assume part of the SK is stored in a m*n P memory
    (*S="TRUE"*) input wire [m-1:0]               P_dout,
    (*S="TRUE"*) output wire                      P_rd_en,
    (*S="TRUE"*) output wire [m-1:0]              P_rd_addr
  );
  
  decryption #(.m({m}), .t({t}), .N({N}), .BLOCK({BLOCK}), .mem_width({mem_width}), .mul_sec_BM({mul_sec_BM}), .mul_sec_BM_step({mul_sec_BM_step})) decryption_inst (
    .clk(clk),
    .start(start),
    .cipher(cipher),
    .poly_g(poly_g),
    .error_recovered(error_recovered),
    .done(done),
    .decryption_fail(decryption_fail),
`ifdef SHARED
    //shared fft signals
    .fft_eva_start_dec(fft_eva_start_dec),
    .fft_coeff_in_dec(fft_coeff_in_dec),
    .fft_rd_en_dec(fft_rd_en_dec),
    .fft_rd_addr_dec(fft_rd_addr_dec),
    .fft_eva_dout_dec(fft_eva_dout_dec),
    .fft_eva_done_dec(fft_eva_done_dec),
`endif
    .P_dout(P_dout),
    .P_rd_en(P_rd_en),
    .P_rd_addr(P_rd_addr)
  );
  
endmodule
""".format(m=m, t=t, N=N, BLOCK=BLOCK, mem_width=mem_width, mul_sec_BM=mul_sec_BM, mul_sec_BM_step=mul_sec_BM_step))

