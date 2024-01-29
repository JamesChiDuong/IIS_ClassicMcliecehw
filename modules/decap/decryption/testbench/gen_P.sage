#!/usr/bin/sage

#
# function: generates a random permutation.
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

import sys

m = int(sys.argv[1])
n = 2^m

fmt = "{0:0" + str(m) + "b}"

set_random_seed(1)

P = Permutations(n).random_element()

for i in range(n):
  bin = fmt.format(P[i]-1)
  sys.stdout.write(bin)
  sys.stdout.write("\n")

 

 
 

