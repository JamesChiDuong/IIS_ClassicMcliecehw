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
ifndef ADDITIVE_FFT

ADDITIVE_FFT_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.SECONDEXPANSION:

include $(COMMON_SRC_PATH)/math/module.mk
include $(ADDITIVE_FFT_SRC_PATH)/reduction/module.mk
include $(ADDITIVE_FFT_SRC_PATH)/radix_conversion/module.mk

ADDITIVE_FFT_SUBMODULES := RADIX_CONVERSION REDUCTION LOG2
ADDITIVE_FFT_SRC = add_FFT.v point_loc.v

ADDITIVE_FFT_SRC += $(foreach module,$(ADDITIVE_FFT_SUBMODULES),$($(module)_SRC))

ADDITIVE_FFT =

additive_fft: $(ADDITIVE_FFT)

# Specify targets for each parameter set
define ADDITIVE_FFT_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
ADDITIVE_FFT_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(ADDITIVE_FFT_SRC))

# Collect all targets
ADDITIVE_FFT += ADDITIVE_FFT_$(1)

$$(BUILD_DIR_SRC_$(1))/add_FFT.v: $$(ADDITIVE_FFT_SRC_PATH)/add_FFT.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call ADDITIVE_FFT_SRC_TEMPLATE,$(par))))

endif
