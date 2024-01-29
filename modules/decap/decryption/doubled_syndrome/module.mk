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

DOUBLED_SYNDROME_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

DOUBLED_SYNDROME_SUBMODULES := GF_MUL GF_SQ MEMORY_MEM POINT_LOCATOR LOG2

include $(COMMON_SRC_PATH)/math/module.mk
include $(COMMON_SRC_PATH)/memory/module.mk
include $(COMMON_SRC_PATH)/point_locator/module.mk

DOUBLED_SYNDROME_SRC = doubled_syndrome.v entry_xor.v gf_inv_syndrome.v vec_mul_syndrome.v point_loc.v

DOUBLED_SYNDROME_SRC += $(foreach module,$(DOUBLED_SYNDROME_SUBMODULES),$($(module)_SRC))

DOUBLED_SYNDROME =

doubled_syndrome: $(DOUBLED_SYNDROME)

# Specify targets for each parameter set
define DOUBLED_SYNDROME_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
DOUBLED_SYNDROME_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(DOUBLED_SYNDROME_SRC))

# Collect all targets
DOUBLED_SYNDROME += DOUBLED_SYNDROME_$(1)

$$(BUILD_DIR_SRC_$(1))/doubled_syndrome.v: $$(DOUBLED_SYNDROME_SRC_PATH)/doubled_syndrome.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/entry_xor.v: $$(DOUBLED_SYNDROME_SRC_PATH)/gen_entry_xor.py
	$$(PYTHON) $$< -n $$(BLOCK) -m $$(m_$(1)) > $$@

# $$(BUILD_DIR_SRC_$(1))/point_loc.v: $$(DOUBLED_SYNDROME_SRC_PATH)/gen_point_loc.py
# 	$$(PYTHON) $$< -t $$(t_$(1)) --gf $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/gf_inv_syndrome.v: $$(MATH_SRC_PATH)/gen_gf_inv.sage
	$$(SAGE) $$< -gf $$(m_$(1)) --name gf_inv_syndrome > $$@

$$(BUILD_DIR_SRC_$(1))/vec_mul_syndrome.v: $$(MATH_SRC_PATH)/gen_vec_mul.py
	$$(PYTHON) $$< -n $$(BLOCK) --gf $$(m_$(1)) --name vec_mul_syndrome > $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call DOUBLED_SYNDROME_SRC_TEMPLATE,$(par))))
