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
ifndef ENCRYPTION

# Dump all variables but the previously defined
# VARS_OLD := $(.VARIABLES)

ENCRYPTION_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

TOPMODULE ?= encryption
ENCRYPTION_SUBMODULES := MEMORY_DUAL

BUILD_DIR ?= $(ENCRYPTION_SRC_PATH)/build
RESULTS_DIR ?= $(BUILD_DIR)/results
COMMON_SRC_PATH ?= $(ENCRYPTION_SRC_PATH)/../../common

include $(ENCRYPTION_SRC_PATH)/../../FPGA/parameters.mk

#TODO clean
PYTHON ?= python3
SAGE ?= sage
IVERILOG ?= iverilog


.SECONDEXPANSION:

ifndef BUILD_DIR_TEMPLATE
define BUILD_DIR_TEMPLATE =

# Parameter-specific build directory root
BUILD_DIR_$(1) = $$(BUILD_DIR)/$$(TOPMODULE)/$(1)
# Parameter-specific source and testbench directory
BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/src
BUILD_DIR_TB_$(1) = $$(BUILD_DIR_$(1))/testbench
#BUILD_DIR_TB_DATA_$(1) = $$(BUILD_DIR_$(1))/testbench/data

endef

$(foreach par, $(PAR_SETS), $(eval $(call BUILD_DIR_TEMPLATE,$(par))))

endif


# Include the submodules after the directory definitions
include $(COMMON_SRC_PATH)/memory/module.mk


# Set the source files of this module
ENCRYPTION_SRC = encryption.v
# Add the sources of the submodules
ENCRYPTION_SRC += $(foreach module,$(ENCRYPTION_SUBMODULES),$($(module)_SRC))

# Define comulated target for generated sources
ifeq (encryption,${TOPMODULE})
.PHONY: sources
sources: $(addprefix sources-, $(PAR_SETS))
endif

ENCRYPTION =

#
# Define the sources targets
#
define ENCRYPTION_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
ENCRYPTION_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(ENCRYPTION_SRC))

# Collect all targets
ENCRYPTION += $$(ENCRYPTION_$(1))

# Define parameter-specific generated source targets
ifeq (encryption,${TOPMODULE})
.PHONY: sources-$(1)
sources-$(1): $$(ENCRYPTION_$(1))

$$(BUILD_DIR_SRC_$(1)):
	mkdir -p $$@
endif

$$(BUILD_DIR_SRC_$(1))/%.v: $$(ENCRYPTION_SRC_PATH)/%.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call ENCRYPTION_SRC_TEMPLATE,$(par))))


# Set the testbench source and data files of this module
ENCRYPTION_TB_SRC = encryption_tb.v

# Define comulated target for generated sources
ifeq (encryption,${TOPMODULE})
.PHONY: testbench
testbench: $(addprefix testbench-, $(PAR_SETS))
endif

# Define comulated target for generated sources
ifeq (encryption,${TOPMODULE})
.PHONY: sim
sim: $(addprefix sim-, $(PAR_SETS))
endif

ENCRYPTION_TB =

#
# Define the testbench targets
#
define ENCRYPTION_TB_TEMPLATE =

# Define all required targets to be included in the modules above
ENCRYPTION_TB_$(1) = $(addprefix $$(BUILD_DIR_TB_$(1))/,$(ENCRYPTION_TB_SRC))

# Collect all targets
ENCRYPTION_TB += $$(ENCRYPTION_TB_$(1))

# Define parameter-specific generated testbench building targets
ifeq (encryption,${TOPMODULE})
.PHONY: testbench-$(1)
testbench-$(1): $$(ENCRYPTION_TB_$(1))

$$(BUILD_DIR_TB_$(1)):
	mkdir -p $$@
endif

$$(BUILD_DIR_TB_$(1))/%.v: $$(ENCRYPTION_SRC_PATH)/testbench/%.v
	cp $$< $$@

# Define parameter-specific generated testbench run targets
ifeq (encryption,${TOPMODULE})
.PHONY: sim-$(1)
sim-$(1): run_encryption_$(1)_sim_iverilog
endif

# Build iverilog binary
# Note: The macro definition file must be at the very beginning.
$$(BUILD_DIR_TB_$(1))/encryption_sim_iverilog: testbench-$(1)\
	| $$(RESULTS_DIR)
	$(IVERILOG) -Wall -Wno-timescale \
	-Dm=$$(m_$(1)) -Dt=$$(t_$(1)) -DN=$$(N_$(1)) \
	-Dmem_width=$$(mem_width_$(1)) -DBLOCK=$$(BLOCK) \
	-Dmul_sec_BM=$$(mul_sec_BM) -Dmul_sec_BM_step=$$(mul_sec_BM_step) \
	-DFILE_MEM_CONSTS=\"$$(BUILD_DIR_SRC_$(1))/mem_consts\" \
	-DFILE_P=\"$$(BUILD_DIR_TB_$(1))/P.in\" \
	-DFILE_POLYG=\"$$(BUILD_DIR_TB_$(1))/poly_g.in\" \
	-DFILE_CIPHER=\"$$(BUILD_DIR_TB_$(1))/cipher.in\" \
	-DFILE_DATA_OUT=\"$$(BUILD_DIR_TB_$(1))/data.out\" \
	-DFILE_RE_ENC_OUT=\"$$(BUILD_DIR_TB_$(1))/re_encryption_res.out\" \
	-DFILE_DOUBLED_SYNDROME_OUT=\"$$(BUILD_DIR_TB_$(1))/doubled_syndrome.out\" \
	-DFILE_VCD=\"$$(BUILD_DIR_TB_$(1))/wave.vcd\" \
	-DFILE_CYCLES_PROFILE=\"$$(RESULTS_DIR)/cycles_profile_$(1).data\" \
	$$(BUILD_DIR_SRC_$(1))/clog2.v \
	$$(BUILD_DIR_TB_$(1))/encryption_tb.v \
	$$(filter-out $$(BUILD_DIR_SRC_$(1))/mem_consts $$(BUILD_DIR_SRC_$(1))/clog2.v,$$(sort $$(ENCRYPTION_$(1)))) \
	-o $$@

# Run the iverilog binary
run_encryption_$(1)_sim_iverilog: $$(BUILD_DIR_TB_$(1))/encryption_sim_iverilog
	$$<
	@diff $$(BUILD_DIR_TB_$(1))/data.out $$(BUILD_DIR_TB_$(1))/error.in \
	&& echo "Test Passed!"

endef

$(foreach par, $(PAR_SETS), $(eval $(call ENCRYPTION_TB_TEMPLATE,$(par))))

ifeq (encryption,${TOPMODULE})
# Add the build directory as order-only-prerequisites to every source file target
$(ENCRYPTION) $(ENCRYPTION_TB): | $$(@D)

$(RESULTS_DIR):
	mkdir -p $@
endif

# clean_encryption_src_$(1):
# 	rm -rf $$(DEC_SRC_$(1))

# clean_encryption_src: $(addprefix clean_, $(BUILD_ENCRYPTION_SRC))

# Dump all defined variable
# $(foreach v,                                        \
#   $(filter-out $(VARS_OLD) VARS_OLD,$(sort $(.VARIABLES))), \
#   $(info > $(v) = $($(v))))

endif
