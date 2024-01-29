# This (sub-)makefile is part of the Classic McEliece hardware source code.
# 
# Copyright (C) 2022
#
# Authors: Norman Lahr <norman@lahr.email>
# 
# This source code is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
# 
# This source code is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# this source code. If not, see <https://www.gnu.org/licenses/>. 

BERLEKAMP_MASSEY_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

BERLEKAMP_MASSEY_SUBMODULES := GF_MUL LOG2

include $(COMMON_SRC_PATH)/math/module.mk

BERLEKAMP_MASSEY_SRC = BM.v \
	vec_mul_multi_BM.v \
	vec_mul_BM.v \
	entry_sum.v \
	BM_step.v \
	vec_mul_multi_BM_step.v \
	vec_mul_BM_step.v \
	GFE_inv_BM_step.v

BERLEKAMP_MASSEY_SRC += $(foreach module,$(BERLEKAMP_MASSEY_SUBMODULES),$($(module)_SRC))

BERLEKAMP_MASSEY =

berlekamp_massey: $(BERLEKAMP_MASSEY)

# Specify targets for each parameter set
define BERLEKAMP_MASSEY_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
BERLEKAMP_MASSEY_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(BERLEKAMP_MASSEY_SRC))

# Collect all targets
BERLEKAMP_MASSEY += BERLEKAMP_MASSEY_$(1)

$$(BUILD_DIR_SRC_$(1))/BM.v: $$(BERLEKAMP_MASSEY_SRC_PATH)/BM.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/vec_mul_multi_BM.v: $$(MATH_SRC_PATH)/gen_vec_mul_multi.py
	$$(PYTHON) $$< -n $$(t_mul_ceil_BM_$(1)) --sec $$(mul_sec_BM) --gf $$(m_$(1)) --name vec_mul_multi_BM --name_sub vec_mul_BM > $$@

$$(BUILD_DIR_SRC_$(1))/vec_mul_BM.v: $$(MATH_SRC_PATH)/gen_vec_mul.py
	$$(PYTHON) $$< -n $$(mul_sec_BM) --gf $$(m_$(1)) --name vec_mul_BM > $$@

$$(BUILD_DIR_SRC_$(1))/entry_sum.v: $$(BERLEKAMP_MASSEY_SRC_PATH)/gen_entry_sum.py
	$$(PYTHON) $$< -N $$(entrylen_$(1)) -m $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/BM_step.v: $$(BERLEKAMP_MASSEY_SRC_PATH)/BM_step.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/vec_mul_multi_BM_step.v: $$(MATH_SRC_PATH)/gen_vec_mul_multi.py
	$$(PYTHON) $$< -n $$(t_mul_ceil_BM_step_$(1)) --sec $$(mul_sec_BM_step) --gf $$(m_$(1)) --name vec_mul_multi_BM_step --name_sub vec_mul_BM_step > $$@

$$(BUILD_DIR_SRC_$(1))/GFE_inv_BM_step.v: $$(MATH_SRC_PATH)/gen_gf_inv.sage
	$$(SAGE) $$< -gf $$(m_$(1)) --name GFE_inv_BM_step > $$@

$$(BUILD_DIR_SRC_$(1))/vec_mul_BM_step.v: $$(MATH_SRC_PATH)/gen_vec_mul.py
	$$(PYTHON) $$< -n $$(mul_sec_BM_step) --gf $$(m_$(1)) --name vec_mul_BM_step > $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call BERLEKAMP_MASSEY_SRC_TEMPLATE,$(par))))
