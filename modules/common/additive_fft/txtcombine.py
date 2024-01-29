'''
 * Function: combine two text files.
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

import math
import argparse
import sys

parser = argparse.ArgumentParser(description='combine two txt files row by row.',
								formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-f1', '--file1', dest='f1', type=str, required=True,
				   help='first file')

parser.add_argument('-f2', '--file2', dest='f2', type=str, required=True,
				   help='second file')

parser.add_argument('-f', '--factor', dest='f', type=int, required=True, default=0,
          help='configuration of the memory') 

args = parser.parse_args()

file1 = args.f1
file2 = args.f2
factor = args.f

with open(file1, 'r') as f1, open(file2, 'r') as f2:
  for x, y in zip(f1, f2):
    x = x.strip()
    y = y.strip()
    if not x.startswith("//"):
      for i in range(int(math.pow(2, factor))):
        sys.stdout.write(y[i*len(y)//int(math.pow(2, factor)):(i+1)*len(y)//int(math.pow(2, factor))])
        sys.stdout.write(x[i*len(x)//int(math.pow(2, factor)):(i+1)*len(x)//int(math.pow(2, factor))])
      sys.stdout.write("\n")
	
