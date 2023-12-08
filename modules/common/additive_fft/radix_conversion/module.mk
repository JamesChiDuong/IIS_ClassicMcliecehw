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

RADIX_CONVERSION_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

RADIX_CONVERSION_SUBMODULES := GF_MUL

include $(COMMON_SRC_PATH)/math/module.mk

RADIX_CONVERSION_SRC = rad_conv_twisted.v \
	rad_conv.v #\
	# vec_mul_multi_twist.v \
	# vec_mul_multi_BM.v \
	# vec_mul_multi_BM_step.v

RADIX_CONVERSION_SRC += $(foreach module,$(RADIX_CONVERSION_SUBMODULES),$($(module)_SRC))

RADIX_CONVERSION =

radix_conversion: $(RADIX_CONVERSION)

# Specify targets for each parameter set
define RADIX_CONVERSION_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
RADIX_CONVERSION_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(RADIX_CONVERSION_SRC))

# Collect all targets
RADIX_CONVERSION += RADIX_CONVERSION_$(1)

$$(BUILD_DIR_SRC_$(1))/rad_conv_twisted.v: $$(RADIX_CONVERSION_SRC_PATH)/gen_rad_conv_twisted_single_coeff.sage
	$$(SAGE) $$< -n $$(entrylen_$(1)) --gf $$(m_$(1)) -p $$(sec) > $$@

$$(BUILD_DIR_SRC_$(1))/rad_conv.v: $$(RADIX_CONVERSION_SRC_PATH)/gen_rad_conv_single_coeff.sage
	$$(SAGE) $$< -n $$(entrylen_$(1)) --gf $$(m_$(1)) -p $$(sec) > $$@

# $$(BUILD_DIR_SRC_$(1))/vec_mul_multi_twist.v: $$(RADIX_CONVERSION_SRC_PATH)/gen_vec_mul_multi.py
# 	$$(PYTHON) $$< -n $$(entrylen_$(1)) --sec $$(sec) --gf $$(m_$(1)) --name vec_mul_multi_twist --name_sub vec_mul_twist > $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call RADIX_CONVERSION_SRC_TEMPLATE,$(par))))
