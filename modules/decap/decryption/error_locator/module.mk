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

ERROR_LOCATOR_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ERROR_LOCATOR_SUBMODULES := POINT_LOCATOR LOG2

include $(COMMON_SRC_PATH)/point_locator/module.mk
include $(COMMON_SRC_PATH)/math/module.mk

ERROR_LOCATOR_SRC = error_locator.v

ERROR_LOCATOR_SRC += $(foreach module,$(ERROR_LOCATOR_SUBMODULES),$($(module)_SRC))

ERROR_LOCATOR =

error_locator: $(ERROR_LOCATOR)

# Specify targets for each parameter set
define ERROR_LOCATOR_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
ERROR_LOCATOR_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(ERROR_LOCATOR_SRC))

# Collect all targets
ERROR_LOCATOR += ERROR_LOCATOR_$(1)

$$(BUILD_DIR_SRC_$(1))/error_locator.v: $$(ERROR_LOCATOR_SRC_PATH)/error_locator.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call ERROR_LOCATOR_SRC_TEMPLATE,$(par))))
