#
# Copyright (C) 2016
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

all: systemize_tb

N=16
L=768
K=3488

clog2.v: ../../../math/gen_log2.py
	python $^ > $@

comb_SA.v: ../gen_comb_SA.py
	python ../gen_comb_SA.py -n $N --name comb_SA > comb_SA.v

systemize_tb: clog2.v systemize_tb.v ../../../memory/mem.v comb_SA.v ../processor_AB.v ../processor_B.v ../step.v ../phase.v ../systemizer.v
	iverilog -Wall -Wno-timescale -DN=$N -DL=$L -DK=$K $^ -o systemize_tb

clean:
	rm -rf clog2.v comb_SA.v systemize_tb data.in data.out gen_test.sage.py systemize_tb.vcd verify_test.sage.py 

