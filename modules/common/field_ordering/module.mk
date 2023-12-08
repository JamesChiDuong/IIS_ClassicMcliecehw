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
ifndef FIELD_ORDERING

FIELD_ORDERING_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

FIELD_ORDERING_SUBMODULES := MERGESORT

include $(FIELD_ORDERING_SRC_PATH)/mergesort/module.mk

FIELD_ORDERING_SRC = field_ordering.v

FIELD_ORDERING_SRC += $(foreach module,$(FIELD_ORDERING_SUBMODULES),$($(module)_SRC))

FIELD_ORDERING =

field_ordering: $(FIELD_ORDERING)

# Specify targets for each parameter set
define FIELD_ORDERING_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
FIELD_ORDERING_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(FIELD_ORDERING_SRC))

# Collect all targets
FIELD_ORDERING += FIELD_ORDERING_$(1)

$$(BUILD_DIR_SRC_$(1))/field_ordering.v: $$(FIELD_ORDERING_SRC_PATH)/field_ordering.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call FIELD_ORDERING_SRC_TEMPLATE,$(par))))

endif
