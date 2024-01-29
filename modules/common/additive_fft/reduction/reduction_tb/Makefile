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


mul_fft_tot = 128
m = 11
#num_power = int(math.log(num, 2)) # 128 = 2^7
#mem_width = int(math.pow(2, (gf-num_power)))//2
mem_width = 8
num_power = 7

factor = $(shell python3 -c "import math; print(int(math.ceil(math.log($(mem_width), 2))-($(m)-math.ceil(math.log($(mul_fft_tot), 2))-1)))")


GEN_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/gen

COMMON_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../../../)


include ../gen.mk
include ../sources.mk

$(GEN_DIR)/gf_mul.v: $(COMMON_DIR)/galois_field/gen_mul.sage
	sage $(COMMON_DIR)/galois_field/gen_mul.sage --gf $(m) > $(GEN_DIR)/gf_mul.v


SOURCES += reduction_tb.v


reduction_tb: $(SOURCES)
	iverilog -Wall -Wno-timescale -Dnum=$(mul_fft_tot) -Dgf=$(m) -Dmem_width=$(mem_width) -Dnum_power=$(num_power) -DFILE_MEM_CONSTS=\"gen/mem_consts\" $^ -o reduction_tb

poly.txt: ../../gen_test_poly.sage
	sage ../../gen_test_poly.sage -n $(mul_fft_tot) --gf $(m) -s 1 > poly.txt

coeff_in.txt: ../../radix_conversion/gen_test_rad_conv_out.sage poly.txt
	sage ../../radix_conversion/gen_test_rad_conv_out.sage -n $(mul_fft_tot) --gf $(m) poly.txt > coeff_in.txt

sol.txt: ../../gen_test_eval_out.sage poly.txt
	sage ../../gen_test_eval_out.sage -n $(mul_fft_tot) --gf $(m) -w $(mem_width) poly.txt > sol.txt

data_out_A.txt: reduction_tb gen/mem_consts coeff_in.txt
	./reduction_tb

data_out_B.txt: data_out_A.txt

data_out.txt: ../../txtcombine.py data_out_A.txt data_out_B.txt
	@python3 ../../txtcombine.py -f1 data_out_A.txt -f2 data_out_B.txt -f $(factor) > data_out.txt

run: sol.txt data_out.txt
	@diff <(sed '/^\s*$$/d' sol.txt) <(grep -v "//" data_out.txt) && echo "Result matches theoretical solution"

clean:
	rm -f *.txt gen/*.v reduction_tb reduction_tb.vcd
