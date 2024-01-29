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
ifndef SHAKE256

SHAKE256_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SHAKE256_SRC = control_path.v  data_path.v  keccak_math.v  keccak_pkg.v  keccak_top.v rc.v  stateram_inference.v  state_ram.v  transform.v

SHAKE256 =

math: $(SHAKE256)

define SHAKE256_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
SHAKE256_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(SHAKE256_SRC))

# Collect all targets
SHAKE256 += $$(SHAKE256_$(1))

$$(BUILD_DIR_SRC_$(1))/%.v: $(SHAKE256_SRC_PATH)/%.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call SHAKE256_SRC_TEMPLATE,$(par))))

endif
