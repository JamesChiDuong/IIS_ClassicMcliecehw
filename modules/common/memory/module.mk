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

# Avoid multiple includes
ifndef MEMORY

MEMORY_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include $(COMMON_SRC_PATH)/math/module.mk

MEMORY_SUBMODULES := LOG2

MEMORY_MEM_SRC = mem.v

MEMORY_SINGLE_SRC = mem_single.v

MEMORY_DUAL_SRC = mem_dual.v

MEMORY_SRC = $(MEMORY_SINGLE_SRC) $(MEMORY_DUAL_SRC)

MEMORY =

memory: $(MEMORY)

define MEMORY_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
MEMORY_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(MEMORY_SRC))

# Collect all targets
MEMORY += $$(MEMORY_$(1))

$$(BUILD_DIR_SRC_$(1))/mem.v: $$(MEMORY_SRC_PATH)/mem.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/mem_single.v: $$(MEMORY_SRC_PATH)/mem_single.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/mem_dual.v: $$(MEMORY_SRC_PATH)/mem_dual.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call MEMORY_SRC_TEMPLATE,$(par))))

endif


