#
# Function: generate a random polynomial.
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

import argparse

parser = argparse.ArgumentParser(description='Generate test polynomial.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--numc', dest='n', type=int, required=True,
          help='number of coeffs')
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
parser.add_argument('-s', '--seed', dest='seed', type=int, required=False, default=None,
          help='seed')
args = parser.parse_args()

format_str = "{0:0" + str(args.m) + "b}"

K.<a> = GF(2^args.m)
Kx.<x> = K[]

if args.seed:
  set_random_seed(args.seed)

g = Kx.random_element(args.n-1)

for i in reversed(g.coefficients()):
  bin_coeff = format_str.format(i.integer_representation())
  sys.stdout.write(bin_coeff)

sys.stdout.write("\n")
  
