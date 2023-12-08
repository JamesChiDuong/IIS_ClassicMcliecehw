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
ifndef POINT_LOCATOR

POINT_LOCATOR_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

POINT_LOCATOR_SUBMODULES :=

POINT_LOCATOR_SRC = point_loc.v

POINT_LOCATOR_SRC += $(foreach module,$(POINT_LOCATOR_SUBMODULES),$($(module)_SRC))

POINT_LOCATOR =

point_locator: $(POINT_LOCATOR)

# Specify targets for each parameter set
define POINT_LOCATOR_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
POINT_LOCATOR_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(POINT_LOCATOR_SRC))

# Collect all targets
POINT_LOCATOR += POINT_LOCATOR_$(1)

$$(BUILD_DIR_SRC_$(1))/point_loc.v: $$(POINT_LOCATOR_SRC_PATH)/gen_point_loc.py
	$$(PYTHON) $$< -t $$(t_$(1)) --gf $$(m_$(1)) > $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call POINT_LOCATOR_SRC_TEMPLATE,$(par))))

endif
