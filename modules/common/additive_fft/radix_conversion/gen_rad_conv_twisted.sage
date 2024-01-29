#
# Function: generate rad_conv+twist module.
# Copyright (C) 2018
# Authors: Wen Wang <wen.wang.ww349@yale.edu>
#          Ruben Niederhagen <ruben@polycephaly.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# parameterized twisted radix conversion module

import argparse
import math

parser = argparse.ArgumentParser(description='Generate rad_conv module.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)          
parser.add_argument('-n', '--num', dest='n', type=int, required= True,
          help='number of coeffs')
parser.add_argument('-p','--sec','--par', dest='par', type=int, required=False, default=1,
          help='parallelism')
parser.add_argument('-m','--gf', dest='gf', type=int, required=True, default=13,
          help='field 2^m')
args = parser.parse_args()

num = args.n
gf = args.gf
twist_count = int(math.log(num, 2))-1
 
F2.<x> = GF(2)[]

F.<a> = GF(2^gf, modulus="first_lexicographic")

basis = [ a^i for i in reversed(range(gf)) ]

def transpose(L):
  ret = []
  for i in range(gf):
    ele = sum([((L[j] >> i) & 1) * 2^j for j in range(num)])
    ret.append(ele)
  return ret

L = []

for i in range(gf-1, gf-twist_count-1, -1):
  basis = [ basis[j] / basis[i] for j in range(i)]
  basis = [ e^2 + e for e in basis ]
  L.append(basis[-1])

twist = []

for i in range(len(L)):
  r = 2^(i+1)
  sc = []
  for j in range(num//r):
    for k in range(r):
      sc.append( (L[i]^j).integer_representation())
  sc_tr = transpose(sc)
  a = ""
  for i in range(num):
    a += ("{0:0%db}" %gf).format(sc[num-1-i]) 
  twist.append(a)

print("// module for radix conversion & twisting")
 
print("""
module rad_conv_twisted (
  input  wire          clk,
  input  wire          start,
  input  wire [{0}:0] coeff_in,
  output wire [{0}:0] coeff_out,
  output wire          done 
);
 
reg [{2}:0] round = {3}'b0;

wire mul_done;

reg running = 1'b0;

always @(posedge clk)
  begin
    running <= start ? 1'b1 :
               done ? 1'b0 :
               running;
               
    round <= start ? {3}'b0 :
             mul_done ? round + {3}'b1 : round;
  end
""".format(num*gf-1, num*gf, int(math.log(twist_count, 2)), int(math.log(twist_count, 2))+1))

 
print("""reg [{0}:0] vec_b = {1}'b0;
 
wire [{0}:0] vec_c;
 
wire [{0}:0] poly_out;
reg [{0}:0] poly_out_buffer = {1}'b0;

always @(posedge clk)
  begin
    poly_out_buffer <= poly_out;
    
    vec_b <= (round == {2}'d0) ?""".format(num*gf-1, num*gf, int(math.log(twist_count, 2))+1))
    
for i in range(twist_count):
  print("             {1}'b{0} :".format(twist[i], num*gf))
  if (i < (twist_count-1)):
    print("             (round == {1}'d{0}) ?".format(i+1, int(math.log(twist_count, 2))+1))
  else:
    print("""             {0}'b0;
  end""".format(num*gf))

print("""
reg mul_start_buffer = 1'b0;
reg mul_start = 1'b0;

reg done_buffer = 1'b0;

assign done = done_buffer;

assign coeff_out = vec_c; 

reg [{0}:0] poly_in_buffer = {2}'b0;

always @(posedge clk)
  begin
    poly_in_buffer <= start ? coeff_in : vec_c;
    
    mul_start_buffer <= done ? 1'b0 : (start | (running && mul_done));
    mul_start <= mul_start_buffer;
    
    done_buffer <= (running && mul_done && (round == {4}'d{1}));
  end
""".format(num*gf-1, twist_count-1, num*gf, int(math.log(twist_count, 2)), int(math.log(twist_count, 2))+1))

print("""
rad_conv rad_conv_inst (
  .clk(clk),
  .poly_in(poly_in_buffer),
  .round(round),
  .poly_out(poly_out)
);

vec_mul_multi_twist vec_mul_multi_twist_inst (
  .clk(clk),
  .start(mul_start),
  .vec_a(poly_out_buffer),
  .vec_b(vec_b),
  .vec_c(vec_c),
  .done(mul_done)
);
 
endmodule
""".format(int(math.log(twist_count, 2))+1))

