#
# Function: generate module rad_conv.
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

# parameterized radix conversion module

import argparse
import math
import re

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
#print(twist_count)

F.<a> = GF(2^gf)

K = PolynomialRing(F, 'g', num)
K.inject_variables(verbose=False)


din = []

for i in reversed(range(num)):
  din.append(eval('g'+str(i)))
  
# round = 0, F000 + 0F00
def one_rad_conv(round, in_list):
  length = len(in_list)
  out_list = in_list
  section = int(num/pow(2, round))
  for i in range(int(length/section)):
    for j in range(int(section/4)):
      start_loc = i*section
      out_list[start_loc+j+int(section/4)] += out_list[start_loc+j]
    for j in range(int(section/4)):
      start_loc = i*section+int(section/4)
      out_list[start_loc+j+int(section/4)] += out_list[start_loc+j]
  return out_list

def str_convert(s0):
    if (s0 == '1'):
        return '{0}\'b1'.format(gf)
    s1 = s0.replace(' 1', ' {0}\'b1'.format(gf))
    pattern = re.compile('g[0-9]+')
    while True:
        result = pattern.search(s1)
        if result == None:
            break
        begin = result.span()[0]
        end = result.span()[1]
        temp1 = gf*int(s1[begin:end][1:])
        temp2 = temp1 + gf - 1
        new = 'g[%d:%d]' % (temp2, temp1)
        s1 = s1[:begin] + new + s1[end:]
    return s1

print("""
module rad_conv (
  input wire          clk,
  input wire [{0}:0]  poly_in,
  input wire [{1}:0]    round,
  output wire [{0}:0] poly_out 
);
""".format(gf*num-1, int(math.log(twist_count, 2))))

for i in range(1, twist_count+1):
  print("wire [{0}:0] poly_twist_in_{1};".format(gf*num-1, i))

print("")
 
for i in range(0, twist_count):
  print("// output for the {0}_th sub radix conversion routine".format(twist_count-i))
  new_coeff = []
  for k in reversed(range(num)):
    new_coeff.append(eval('g'+str(k)))
  new_coeff = one_rad_conv(i, new_coeff)
  for j in range(num):
    coeff = str(new_coeff[j])
    coeff = coeff.replace('+', "^")
    coeff = str_convert(coeff)
    if (i == 0):
      coeff = coeff.replace('g', 'poly_in')
    else:
      coeff = coeff.replace('g', 'poly_twist_in_{0}'.format(i))
    print("assign poly_twist_in_{0}[{1}:{2}] = {3};".format(i+1, (num-j)*gf-1, (num-j-1)*gf, coeff))
  print("")

print("assign poly_out = (round == {1}'b0) ? poly_twist_in_{0} :".format(twist_count, int(math.log(twist_count, 2))+1))
for i in range(1, twist_count-1):
  print("                  (round == {2}'d{0}) ? poly_twist_in_{1} :".format(i, twist_count-i, int(math.log(twist_count, 2))+1))
print("                  poly_twist_in_1;")

print("")

print("endmodule")

      
    
    
  
  
  




































