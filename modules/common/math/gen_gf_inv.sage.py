

# This file was *autogenerated* from the file /home/james/Documents/IIS/FPGA/Cryto/ClassicMceliehw_FPGA/test/ClassicMceliehw_FPGA/modules/common/math/gen_gf_inv.sage
from sage.all_cmdline import *   # import sage library

_sage_const_13 = Integer(13); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_3 = Integer(3)#
# Copyright (C) 2018
# Authors: Wen Wang <wen.wang.ww349@yale.edu>
#          Ruben Niederhagen <ruben@polycephaly.org>
# Function: generate the module for finite field element inversion.
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

import argparse, sys

parser = argparse.ArgumentParser(description='Generate result of rad_conv_twisted.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-m', '--field', '-gf', '--gf', dest='gf', type=int, required=True, default=_sage_const_13 ,
          help='finite field (GF(2^m))')
parser.add_argument('--name', dest='name', type=str, default='GFE_inv',
          help = 'name for generated module; default: GFE_inv')

args = parser.parse_args()

K = GF(_sage_const_2 **args.gf, modulus="first_lexicographic", names=('a',)); (a,) = K._first_ngens(1)

fmt = "mem[{{0}}] = {0}'b{{1:0{0}b}};".format(args.gf+_sage_const_1 )

print("""module {3} (
  input wire        clk,
  input wire [{0}:0] din_A,
  output wire [{0}:0] dout_A,
  output wire dout_en_A,
  input wire [{0}:0] din_B,
  output wire [{0}:0] dout_B,
  output wire dout_en_B
);

parameter DELAY = -1;

generate
if (DELAY != 1) begin
    ERROR_module_parameter_DELAY_not_set_correctly_in_GF_INV ASSERT_ERROR();
end
endgenerate

reg [{1}:0] mem [0:{2}];

initial begin""".format(args.gf-_sage_const_1 , args.gf, _sage_const_2 **args.gf-_sage_const_1 , args.name))

print("  " + fmt.format(_sage_const_0 , _sage_const_0 ))

if args.gf == _sage_const_1 :
  print("  " + fmt.format(_sage_const_1 , _sage_const_3 ))
else:
  for i in range(_sage_const_1 , _sage_const_2 **args.gf):
    v = K.fetch_int(i)
    v = _sage_const_1 /v
    print("  " + fmt.format(i, _sage_const_2 **args.gf | v.integer_representation()))

print("""end

reg [{0}:0] dout_A_tmp;

always @(posedge clk) 
begin
  dout_A_tmp <= mem[din_A];
end

assign dout_A = dout_A_tmp[{1}:0];
assign dout_en_A = dout_A_tmp[{0}];

reg [{0}:0] dout_B_tmp;

always @(posedge clk) 
begin
  dout_B_tmp <= mem[din_B];
end

assign dout_B = dout_B_tmp[{1}:0];
assign dout_en_B = dout_B_tmp[{0}];

endmodule
""".format(args.gf, args.gf-_sage_const_1 ))


