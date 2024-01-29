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
ifndef SYSTEMIZER_SPGF2_REDO

SYSTEMIZER_SPGF2_REDO_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SYSTEMIZER_SPGF2_REDO_SUBMODULES := LOG2 GF_MAD GF_INV MEMORY_DUAL

include $(COMMON_SRC_PATH)/math/module.mk
include $(COMMON_SRC_PATH)/memory/module.mk


SYSTEMIZER_SPGF2_REDO_SRC = systemizer.v \
	phase.v \
	comb_SA.v \
	processor_AB.v \
	processor_B.v \
	mem_quad.v


SYSTEMIZER_SPGF2_REDO_SRC += $(foreach module,$(SYSTEMIZER_SPGF2_REDO_SUBMODULES),$($(module)_SRC))

SYSTEMIZER_SPGF2_REDO =

systemizer_spgf2_redo: $(SYSTEMIZER_SPGF2_REDO)

# Specify targets for each parameter set
define SYSTEMIZER_SPGF2_REDO_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
SYSTEMIZER_SPGF2_REDO_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(SYSTEMIZER_SPGF2_REDO_SRC))

# Collect all targets
SYSTEMIZER_SPGF2_REDO += SYSTEMIZER_SPGF2_REDO_$(1)

$$(BUILD_DIR_SRC_$(1))/comb_SA.v: $$(SYSTEMIZER_SPGF2_REDO_SRC_PATH)/gen_comb_SA.py
	$$(PYTHON) $$< -n $$(N_H_elim_$(1)) --name comb_SA > $$@

$$(BUILD_DIR_SRC_$(1))/processor_AB.v: $$(SYSTEMIZER_SPGF2_REDO_SRC_PATH)/processor_AB.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/processor_B.v: $$(SYSTEMIZER_SPGF2_REDO_SRC_PATH)/processor_B.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/phase.v: $$(SYSTEMIZER_SPGF2_REDO_SRC_PATH)/phase.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/systemizer.v: $$(SYSTEMIZER_SPGF2_REDO_SRC_PATH)/systemizer.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/mem_quad.v: $$(SYSTEMIZER_SPGF2_REDO_SRC_PATH)/mem_quad.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call SYSTEMIZER_SPGF2_REDO_SRC_TEMPLATE,$(par))))

endif
