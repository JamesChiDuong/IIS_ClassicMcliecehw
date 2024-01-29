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
ifndef DELAY

DELAY_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

DELAY_SUBMODULES :=

DELAY_SRC = delay.v

DELAY_SRC += $(foreach module,$(DELAY_SUBMODULES),$($(module)_SRC))

DELAY =

delay: $(DELAY)

# Specify targets for each parameter set
define DELAY_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
DELAY_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(DELAY_SRC))

# Collect all targets
DELAY += DELAY_$(1)

$$(BUILD_DIR_SRC_$(1))/delay.v: $$(DELAY_SRC_PATH)/delay.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call DELAY_SRC_TEMPLATE,$(par))))

endif
