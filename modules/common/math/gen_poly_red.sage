#
# Function: generates polynomial reduction module.
#
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

# generate module: koa_red
# reduction for a 237-coeff poly on: x^119 + x^8 + 1
# 57-coeff: x^29 + x^2 + 1
# limited to the situation when the reduction polynomial is a trinomial

import argparse
import math
import re


parser = argparse.ArgumentParser(description='Generate module for polynomial reduction.',
								formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-t', '--poly_deg', dest='t', type=int, required=True,
				   help='degree of the polynomial')
parser.add_argument('-m','--gf', dest='gf', type=int, required=True, default=13,
          help='field 2^m')

				   
args = parser.parse_args()

t = args.t
gf = args.gf

C = 2*t-1

F = GF(2)
K = PolynomialRing(GF(2), 'f', C)
K.inject_variables(verbose=False)

Kx.<x> = K[]

poly_in = Kx.zero()

for i in range(C):
    poly_in += eval('f'+str(i)) * x^i


Fgf = GF(2^gf, name='z', modulus="first_lexicographic")
Fgf.inject_variables(verbose=False)

if t == 20:
  irr_pol = x^20+x^3+1
elif t == 50:
  irr_pol = x^50+x^5+x^2+z
elif t == 64:
  irr_pol = x^64+x^3+x+z
elif t == 96:
  irr_pol = x^96+x^10+x^9+x^6+1
elif t == 119:
  irr_pol = x^119+x^8+1
elif t == 128:
  irr_pol = x^128+x^7+x^2+x+1
else:
  # the following is not guaranteed to be irreducible in the acutal extension ring!
  irr_pol = PolynomialRing(GF(2), 'x').irreducible_element(t, algorithm="first_lexicographic")

  sys.stderr.write("WARINING: Check irreducible polynomial for polynomail reduction!\n")


poly_in = poly_in.mod(irr_pol)

poly_in = poly_in.coefficients()

# Generate multiples by z for some of the irreducible polynomials.
def times_z(var):
  f_elem = Kx.zero()

  for i in range(gf):
      f_elem += eval('f'+str(i)) * x^i
  
  f_elem *= x

  term = f_elem.mod(Fgf.modulus())

  a = str(term)
  a = re.sub("\*x\^[0-9]* \+", ",", a, count=0)
  a = re.sub("\*x \+", ",", a, count=0)
  a = a.replace("+", "^")

  a = re.sub(r"f([0-9]*)", var + r"[\1]", a, count=0)

  print("wire [" + str(gf-1) + ":0] z" + var + ";")
  print("")
  print("assign z" + var + " = {" + a + "};")
  print("")


print("//reduction for a {0}-coeffs polynomials".format(C))

print("")

print("""module poly_red (
  input  wire  			    start,
  input  wire 			    clk,
  input  wire  [{0}:0]  poly_in,
  output wire  [{1}:0]  poly_out,
  output wire  			    done
);
""".format(C*gf-1, t*gf-1))

for i in range(C):
  #print("wire [{0}:{1}] f{2};".format(i*gf+(gf-1), i*gf, i))
  print("wire [{0}:{1}] f{2};".format(gf-1, 0, i))

print("")

for i in range(C):
  print("assign f{0} = poly_in[{1}:{2}];".format(i, i*gf+(gf-1), i*gf))

print("")

# If the constant in the irreducible polynomial is z, we need factors by z.
# Not sure which - so let's do all...
if "z" in str(irr_pol):
  for i in range(C):
    times_z("f" + str(i))
  
print("""reg [{0}:0] poly_out_buffer = 0;

always @(posedge clk)
  begin""".format(t*gf-1))

for i in range(t):
  a = str(poly_in[i])
  a = a.replace('+', '^')
  a = a.replace('(z)*', 'z')
  a = a.replace('z*', 'z')
  #a = re.sub(r"f([0-9]+)", r"poly_in["+str(int(gf*\1+(gf-1)))+':'+str(int(gf*\1))+"]", a)
  print(("""    poly_out_buffer[{0}:{1}] <= (start == 0) ? """ + str(gf) + """'b0 : {2};""").format(i*gf+(gf-1), i*gf, a))
print("  end" )

print("")

print("assign poly_out = poly_out_buffer;")
print("")

print("""reg done_buffer = 0;

always @(posedge clk)
  begin
    done_buffer <= start;
  end

assign done = done_buffer;
""")

print("endmodule")
print("")
