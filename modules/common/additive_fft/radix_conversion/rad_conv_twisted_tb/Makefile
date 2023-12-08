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

SHELL := /bin/bash

all: run

entrylen = 65
num_fft_cyc = 4
m = 13

rad_conv = single_coeff


GEN_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/gen

COMMON_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../../../)

include ../gen.mk
include ../sources.mk

$(GEN_DIR)/gf_mul.v: $(COMMON_DIR)/galois_field/gen_mul.sage
	sage $(COMMON_DIR)/galois_field/gen_mul.sage --gf $(m) > $(GEN_DIR)/gf_mul.v


SOURCES += rad_conv_twisted_tb.v


coeff_in.txt: ../../gen_test_poly.sage
	sage ../../gen_test_poly.sage -n $(entrylen) --gf $(m) -s 1 > coeff_in.txt

sol.txt: ../gen_test_rad_conv_out.sage coeff_in.txt
	sage ../gen_test_rad_conv_out.sage -n $(entrylen) --gf $(m) coeff_in.txt > sol.txt

rad_conv_twisted_tb: $(SOURCES)
	iverilog -Wall -Dnum=$(entrylen) -Dgf=$(m) -Wno-timescale $^ -o rad_conv_twisted_tb

data_out.txt: rad_conv_twisted_tb coeff_in.txt
	./rad_conv_twisted_tb

run: sol.txt data_out.txt
	@diff sol.txt data_out.txt && echo "Test Passed!"

clean:
	rm -f *.sage.py ../*.sage.py ../../../../gf13/comp/*.sage.py ../../*.sage.py rad_conv_twisted.v rad_conv.v vec_mul_multi_twist.v vec_mul_twist.v vec_mul.v gf_mul.v coeff_in.txt sol.txt data_out.txt rad_conv_twisted_tb rad_conv_twisted.vcd gen/*.v

