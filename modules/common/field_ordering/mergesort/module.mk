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

MERGESORT_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

MERGESORT_SUBMODULES := MEMORY_DUAL

include $(COMMON_SRC_PATH)/memory/module.mk

MERGESORT_SRC = merge_sort.v compare_half.v

MERGESORT_SRC += $(foreach module,$(MERGESORT_SUBMODULES),$($(module)_SRC))

MERGESORT =

mergesort: $(MERGESORT)

# Specify targets for each parameter set
define MERGESORT_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
MERGESORT_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(MERGESORT_SRC))

# Collect all targets
MERGESORT += MERGESORT_$(1)

$$(BUILD_DIR_SRC_$(1))/merge_sort.v: $$(MERGESORT_SRC_PATH)/merge_sort.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/compare_half.v: $$(MERGESORT_SRC_PATH)/compare_half.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call MERGESORT_SRC_TEMPLATE,$(par))))
