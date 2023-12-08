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
parser.add_argument('-mul_sec_BM', dest='mul_sec_BM', type=int, required= True,
          help='number of multipliers in BM module')
parser.add_argument('-mul_sec_BM_step', dest='mul_sec_BM_step', type=int, required= True,
          help='number of multipliers in BM_step module')
 
args = parser.parse_args()

m = args.m

t = args.t

mul_sec_BM = args.mul_sec_BM

mul_sec_BM_step = args.mul_sec_BM_step
 
print("""module main
  #(
    parameter m = {m},   // 2^m is the size of the finite field, m=13
    parameter t = {t},  // number of errors
    parameter mul_sec_BM = {mul_sec_BM},  
    parameter mul_sec_BM_step = {mul_sec_BM_step}
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
  
  BM #(.m({m}), .t({t}), .mul_sec_BM({mul_sec_BM}), .mul_sec_BM_step({mul_sec_BM_step})) DUT (
    .clk(clk),
    .start(start),
    .synd_dout(synd_dout),
    .synd_rd_en(synd_rd_en),
    .synd_rd_addr(synd_rd_addr),
    .error_loc_poly(error_loc_poly),
    .done(done)
  );
 
  
endmodule
""".format(m=m, t=t, mul_sec_BM=mul_sec_BM, mul_sec_BM_step=mul_sec_BM_step))

