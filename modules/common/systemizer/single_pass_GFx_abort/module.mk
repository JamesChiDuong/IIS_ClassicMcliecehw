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
ifndef SYSTEMIZER_SPGFXA

SYSTEMIZER_SPGFXA_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SYSTEMIZER_SPGFXA_SUBMODULES := GF_MAD GF_INV LOG2 MEMORY_MEM DELAY

include $(COMMON_SRC_PATH)/math/module.mk
include $(COMMON_SRC_PATH)/memory/module.mk
include $(COMMON_SRC_PATH)/delay/module.mk


SYSTEMIZER_SPGFXA_SRC = systemizer.v \
	phase.v \
        step.v \
        processor_AB.v \
        processor_B.v \
	comb_SA.v \
        gf_mad_H_elim.v \
        gf_inv_H_elim.v

SYSTEMIZER_SPGFXA_SRC += $(foreach module,$(SYSTEMIZER_SPGFXA_SUBMODULES),$($(module)_SRC))

SYSTEMIZER_SPGFXA =

systemizer_spgfxa: $(SYSTEMIZER_SPGFXA)

# Specify targets for each parameter set
define SYSTEMIZER_SPGFXA_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
SYSTEMIZER_SPGFXA_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(SYSTEMIZER_SPGFXA_SRC))

# Collect all targets
SYSTEMIZER_SPGFXA += SYSTEMIZER_SPGFXA_$(1)

$$(BUILD_DIR_SRC_$(1))/gf_mad_H_elim.v: $(COMMON_SRC_PATH)/math/gen_gf_mad.sage
	sage $$< -gf 1 --name gf_mad_H_elim > $$@

$$(BUILD_DIR_SRC_$(1))/gf_inv_H_elim.v: $(COMMON_SRC_PATH)/math/gen_gf_inv.sage
	sage $$< -gf 1 --name gf_inv_H_elim > $$@


$$(BUILD_DIR_SRC_$(1))/comb_SA.v: $$(SYSTEMIZER_SPGFXA_SRC_PATH)/gen_comb_SA.py
	$$(PYTHON) $$< -n $$(N_H_elim_$(1)) -m 1 -b $$(N_H_elim_$(1)) --name comb_SA | sed 's/GFE_inv/gf_inv_H_elim/g' > $$@

$$(BUILD_DIR_SRC_$(1))/processor_AB.v: $$(SYSTEMIZER_SPGFXA_SRC_PATH)/processor_AB.v
	sed 's/GFE_inv/gf_inv_H_elim/g; s/GFE_mad gfe_mad_inst/gf_mad_H_elim gfe_mad_inst/g' $$< > $$@

$$(BUILD_DIR_SRC_$(1))/processor_B.v: $$(SYSTEMIZER_SPGFXA_SRC_PATH)/processor_B.v
	sed 's/GFE_inv/gf_inv_H_elim/g; s/GFE_mad gfe_mad_inst/gf_mad_H_elim gfe_mad_inst/g' $$< > $$@

$$(BUILD_DIR_SRC_$(1))/step.v: $$(SYSTEMIZER_SPGFXA_SRC_PATH)/step.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/phase.v: $$(SYSTEMIZER_SPGFXA_SRC_PATH)/phase.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/systemizer.v: $$(SYSTEMIZER_SPGFXA_SRC_PATH)/systemizer.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call SYSTEMIZER_SPGFXA_SRC_TEMPLATE,$(par))))

endif
