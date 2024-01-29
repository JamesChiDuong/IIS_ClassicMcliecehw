#
# Copyright (C) 2018
# Function: generate a random syndrome polynomial as input.
#
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
 
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
          
parser.add_argument('-t', dest='t', type=int, required=True, default=119,
          help='number of errors')
          
parser.add_argument('-s', '--seed', dest='seed', type=int, required=False, default=None,
          help='seed')
args = parser.parse_args()

format_str = "{0:0" + str(args.m) + "b}"

K.<a> = GF(2^args.m, modulus="first_lexicographic")
Kx.<x> = K[]

if args.seed:
  set_random_seed(args.seed)

syndrome = Kx.random_element(2*args.t-1)

for i in (syndrome.coefficients()):
  bin_coeff = format_str.format(i.integer_representation())
  sys.stdout.write(bin_coeff)
  sys.stdout.write("\n")

