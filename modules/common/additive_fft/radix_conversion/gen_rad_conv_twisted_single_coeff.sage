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
parser.add_argument('-m','--gf', dest='gf', type=int, required=True, default=13,
          help='field 2^m')
parser.add_argument('-p','--sec','--par', dest='par', type=int, required=False, default=1,
          help='parallelism')
args = parser.parse_args()

num = args.n
gf = args.gf
par = args.par
twist_count = int(math.ceil(math.log(num, 2)))-1

F2.<x> = GF(2)[]

F.<a> = GF(2^gf, modulus="first_lexicographic")

numc = 1 << int(math.ceil(math.log(num, 2)))

num_par = int(math.ceil(float(num)/par))


basis = [ a^i for i in reversed(range(gf)) ]

def transpose(L):
  ret = []
  for i in range(gf):
    ele = sum([ ((L[j] >> i) & 1) * 2^j for j in range(numc)])
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
  for j in range(numc/r):
    for k in range(r):
      sc.append( (L[i]^j).integer_representation())
  sc_tr = transpose(sc)
  a = ""
  for i in range(numc):
    a += ("{0:0%db}" %gf).format(sc[numc-1-i])
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

reg [{1}:0] round = {2}'b0;

reg mul_done = 1'b0;

reg running = 1'b0;
""".format(num*gf-1, int(math.log(twist_count, 2)), int(math.log(twist_count, 2))+1))

print("""wire [{0}:0] coef;

reg [{1}:0] step = 0;
reg [{1}:0] ctr = 0;

wire [{0}:0] mul_res;
reg [{2}:0] poly_mul = 0;
""".format(gf*par-1, int(math.ceil(math.log(num,2)))-1, gf*num-1, par-1))

for i in range(par):
  print('reg [{0}:0] const_{2} [{1}:0] /* synthesis ramstyle = "M20K" */;'.format(gf-1, ceil(float(num)/par)*twist_count-1, i))

#print('reg [{0}:0] const [{1}:0] /* synthesis ramstyle = "M20K" */;'.format(gf-1, (num*twist_count)-1))

print("""
initial
begin""")

# compute index bounds for memory blocks
bounds = [0]*par

for i in range(par):
  bounds[i] = (QQ(num)/par*i).round()

bounds.append(num)

last_b_idx = [0]*par

for i in range(twist_count):
  
  b_id = 0
  
  for j in range(num):
    if j >= bounds[b_id+1]:
      b_id += 1
      
    print("  const_{par}[{1:{width}}] = {2}'b{3};".format(i, last_b_idx[b_id], gf,
                                                    twist[i][(numc-1-j)*gf:(numc-1-j)*gf+gf],
                                                    width=int(math.ceil(math.log(twist_count*numc/par,10))), par=b_id))
    
    last_b_idx[b_id] += 1

  if (i + 1) < twist_count:
    print("")


print("end")

print("""
reg done_buffer = 1'b0;

assign done = done_buffer;

assign coeff_out = poly_mul;

reg [{0}:0] poly_in_buffer = {2}'b0;

reg  rad_conv_start = 0;
wire rad_conv_done;

reg mul_start;

always @(posedge clk)
begin
  running <= start ? 1'b1 :
             done ? 1'b0 :
             running;

  round <= start ? {4}'b0 :
           mul_done ? round + {4}'b1 : round;

  step <= rad_conv_start ? 0 : 
          running ? step + 1:
          step;

  ctr <= step;

  poly_in_buffer <= start ? coeff_in :
                    mul_done ? poly_mul : poly_in_buffer;

  rad_conv_start <= done ? 1'b0 : (start | (running && mul_done));

  mul_start <= done ? 1'b0 : (running && rad_conv_done);
  mul_done <= mul_start;

  done_buffer <= (running && mul_done && (round == {4}'d{1}));
end
""".format(num*gf-1, twist_count-1, num*gf, int(math.log(twist_count, 2)), int(math.log(twist_count, 2))+1))

print("")

print("""assign rad_conv_done = (step=={3});

rad_conv rad_conv_inst (
  .clk(clk),
  .round(round),
  .step(step),
  .poly_in(poly_in_buffer),
  .coef(coef)
);

reg [{2}:0] coef_buf = {1}'b0;
reg [{2}:0] const_val = {1}'b0;
""".format(gf*num-1, gf*par, gf*par-1, (QQ(num)/par).ceil()))

print("")

print("always @(posedge clk)")
print("begin")
print("  coef_buf <= coef;\n")
for p in range(par):
  print("  const_val[{0}:{1}] <= const_{3}[round*{2} + ctr];".format((p+1)*gf-1, p*gf, bounds[p+1]-bounds[p], p))
print("end")

print("\n")

for p in range(par):
  print("""gf_mul gf_mul_inst{0} (
  .clk(clk),
  .dinA(coef_buf[{1}:{2}]),
  .dinB(const_val[{1}:{2}]),
  .dout(mul_res[{1}:{2}])
);\n""".format(p, gf*(p+1)-1, gf*p))

print("")

print("wire [{0}:0] shift_en;".format(par-1))

print("")

for p in range(par):
  print("assign shift_en[{1}] = ctr <= {0};".format(
        (QQ(num)/par*(p+1)).round() - (QQ(num)/par*p).round(), p))

print("""
always @(posedge clk)
begin""")

for p in range(par):
  if (QQ(num)/par*(p+1)).round()*gf-1 > (QQ(num)/par*p).round()*gf+gf:
    print(("  poly_mul[{0}:{1}] <= shift_en[{6}] ? " +
          "{{mul_res[{2}:{3}], poly_mul[{4}:{5}]}} : poly_mul[{0}:{1}];").format(
       (QQ(num)/par*(p+1)).round()*gf-1,
       (QQ(num)/par*p).round()*gf,
       (p+1)*gf-1,
       p*gf,
       (QQ(num)/par*(p+1)).round()*gf-1,
       (QQ(num)/par*p).round()*gf+gf,
       p))
  else:
    # special case for single coefficient
    print(("  poly_mul[{0}:{1}] <= shift_en[{4}] ? " +
          "mul_res[{2}:{3}] : poly_mul[{0}:{1}];").format(
       (QQ(num)/par*(p+1)).round()*gf-1,
       (QQ(num)/par*p).round()*gf,
       (p+1)*gf-1,
       p*gf,
       p))

print("""end

endmodule
""".format(gf*num-1, gf*par, gf*par-1))

