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

FIXED_WEIGHT_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

FIXED_WEIGHT_SUBMODULES := MEMORY_SINGLE MEMORY_DUAL

include $(COMMON_SRC_PATH)/memory/module.mk

FIXED_WEIGHT_SRC = fixed_weight.v onegen.v

FIXED_WEIGHT_SRC += $(foreach module,$(FIXED_WEIGHT_SUBMODULES),$($(module)_SRC))

FIXED_WEIGHT =

error_locator: $(FIXED_WEIGHT)

# Specify targets for each parameter set
define FIXED_WEIGHT_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
FIXED_WEIGHT_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(FIXED_WEIGHT_SRC))

# Collect all targets
FIXED_WEIGHT += FIXED_WEIGHT_$(1)

$$(BUILD_DIR_SRC_$(1))/%.v: $$(FIXED_WEIGHT_SRC_PATH)/%.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call FIXED_WEIGHT_SRC_TEMPLATE,$(par))))
