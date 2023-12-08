#
# Function: generate radix conversion module.
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

import sys
import math
import argparse

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

rounds = int(math.ceil(math.log(num, 2)))

numc = 1 << int(math.ceil(math.log(num, 2)))

num_par = int(math.ceil(float(num)/par))


def split(A, n=-1, cur=0):
  if n == cur:
    return A

  if len(A) < 4:
    return A

  w = len(A) >> 2

  A0 = A[0:w]
  A1 = A[w:2*w]
  A2 = A[2*w:3*w]
  A3 = A[3*w:4*w]

  A2 = [A2[i] + A3[i] for i in range(len(A2))]
  A1 = [A1[i] + A2[i] for i in range(len(A2))]

  return split(A0 + A1, n, cur+1) + split(A2 + A3, n, cur+1)


sys.stdout.write("""module rad_conv (
  input wire clk,
  input wire [{1}:0] round,
  input wire [{3}:0] step,
  input wire [{0}:0] poly_in,
  output wire [{2}:0] coef
);

""".format(num*gf-1, int(math.ceil(math.log(rounds, 2)))-1, (gf*par)-1,
           int(math.ceil(math.log(num, 2)))-1)
)

for i in range(par):
  sys.stdout.write('reg [{1}:0] poly_const_{par} [0:{0}] /* synthesis ramstyle = "M20K" */;\n'.format(ceil(float(num)/par)*(rounds-1) - 1, num-1, par=i))

sys.stdout.write("\ninitial\nbegin\n")

# compute inedx bounds for memory blocks
bounds = [0]*par

for i in range(par):
  bounds[i] = (QQ(num)/par*i).round()

bounds.append(num)

last_b_idx = [0] * par

for rnd in reversed(range(1, rounds)):
  A = [[i] for i in range(numc)]

  B = split(A, rnd)

  b_id = 0  # memor block id

  for i in range(num):
    v = B[i]
    l = [0]*num

    for x in v:
      if x < num:
        l[x] = l[x] ^^ 1

    if i >= bounds[b_id+1]:
       b_id += 1


    sys.stdout.write("  poly_const_{par}[{0:{width}}] = {1}'b".format(last_b_idx[b_id], num,
                     width=int(math.ceil(math.log(rounds*num/par, 10))), par=b_id))
    sys.stdout.write("".join([str(j) for j in reversed(l)]))
    sys.stdout.write(";\n")

    last_b_idx[b_id] += 1

  if rnd > 1:
    sys.stdout.write("\n")

sys.stdout.write("end\n")

sys.stdout.write("\n")

for i in range(par):
  sys.stdout.write("reg [{0}:0] const{1} = 0;\n".format(num-1, i))

sys.stdout.write("\nalways @(posedge clk)\nbegin\n")
  
for i in range(par):
  sys.stdout.write("  const{0} <= poly_const_{0}[round * {1} + step];\n".format(i, bounds[i+1]-bounds[i]))

sys.stdout.write("end\n\n")

for i in range(par):
  sys.stdout.write("assign coef[{0}:{1}] = ".format(gf*(i+1)-1, gf*i))
  
  sys.stdout.write(" ^ ".join(["(const{3}[{2}] ? poly_in[{0}:{1}] : 0)".format(
                              (j+1)*gf-1, j*gf, j, i) for j in range((QQ(num)/par * i).round(), num)]))

  sys.stdout.write(";\n\n")

sys.stdout.write("endmodule\n\n")

