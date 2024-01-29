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

REDUCTION_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

REDUCTION_SUBMODULES := GF_MUL MEMORY_MEM MEMORY_DUAL DELAY

include $(COMMON_SRC_PATH)/math/module.mk
include $(COMMON_SRC_PATH)/memory/module.mk
include $(COMMON_SRC_PATH)/delay/module.mk

REDUCTION_SRC = reduction.v \
	vec_mul_reduction.v \
	mem_consts

REDUCTION_SRC += $(foreach module,$(REDUCTION_SUBMODULES),$($(module)_SRC))

REDUCTION =

reduction: $(REDUCTION)

# Specify targets for each parameter set
define REDUCTION_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
REDUCTION_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(REDUCTION_SRC))

# Collect all targets
REDUCTION += REDUCTION_$(1)

$$(BUILD_DIR_SRC_$(1))/reduction.v: $$(REDUCTION_SRC_PATH)/gen_reduction.py
	$$(PYTHON) $$< -n $$(num_$(1)) --gf $$(m_$(1)) --mem_width $$(mem_width_$(1)) > $$@

# $$(BUILD_DIR_SRC_$(1))/vec_mul_twist.v: $$(REDUCTION_SRC_PATH)/gen_vec_mul.py
# 	$$(PYTHON) $$< -n $$(sec) --gf $$(m_$(1)) --name vec_mul_twist > $$@

$$(BUILD_DIR_SRC_$(1))/vec_mul_reduction.v: $$(MATH_SRC_PATH)/gen_vec_mul.py
	$$(PYTHON) $$< -n $$(mem_width_$(1)) --gf $$(m_$(1)) --name vec_mul_reduction > $$@

# $$(BUILD_DIR_SRC_$(1))/vec_mul_syndrome.v: $$(REDUCTION_SRC_PATH)/gen_vec_mul.py
# 	$$(PYTHON) $$< -n $$(BLOCK) --gf $$(m_$(1)) --name vec_mul_syndrome > $$@

$$(BUILD_DIR_SRC_$(1))/mem_consts: $$(REDUCTION_SRC_PATH)/gen_consts_mem.sage
	$$(SAGE) $$< -n $$(num_$(1)) --gf $$(m_$(1)) --mem_width $$(mem_width_$(1)) > $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call REDUCTION_SRC_TEMPLATE,$(par))))
