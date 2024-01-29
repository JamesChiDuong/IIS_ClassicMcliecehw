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

# Dump all variables but the previously defined
# VARS_OLD := $(.VARIABLES)

DECRYPTION_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export ROOT_PATH
TOPMODULE ?= decryption
DECRYPTION_SUBMODULES := ADDITIVE_FFT BERLEKAMP_MASSEY ERROR_LOCATOR DOUBLED_SYNDROME LOG2

BUILD_DIR ?= $(DECRYPTION_SRC_PATH)/build
RESULTS_DIR ?= $(BUILD_DIR)/results
COMMON_SRC_PATH ?= $(ROOT_PATH)/modules/common


include $(ROOT_PATH)/modules/FPGA/parameters.mk

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
include $(COMMON_SRC_PATH)/additive_fft/module.mk
include $(DECRYPTION_SRC_PATH)/berlekamp_massey/module.mk
include $(DECRYPTION_SRC_PATH)/error_locator/module.mk
include $(DECRYPTION_SRC_PATH)/doubled_syndrome/module.mk
include $(COMMON_SRC_PATH)/math/module.mk

# Set the source files of this module
DECRYPTION_SRC = main.v decryption.v
# Add the sources of the submodules
DECRYPTION_SRC += $(foreach module,$(DECRYPTION_SUBMODULES),$($(module)_SRC))

# Define comulated target for generated sources
ifeq (decryption,${TOPMODULE})
.PHONY: sources
sources: $(addprefix sources-, $(PAR_SETS))
endif

DECRYPTION =

#
# Define the sources targets
#
define DECRYPTION_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
DECRYPTION_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(DECRYPTION_SRC))

# Collect all targets
DECRYPTION += $$(DECRYPTION_$(1))

# Define parameter-specific generated source targets
ifeq (decryption,${TOPMODULE})
.PHONY: sources-$(1)
sources-$(1): $$(DECRYPTION_$(1))
endif

$$(BUILD_DIR_SRC_$(1)):
	mkdir -p $$@

$$(BUILD_DIR_SRC_$(1))/main.v: $$(DECRYPTION_SRC_PATH)/gen_main.py $$(BUILD_DIR_SRC_$(1))/decryption.v
	$$(PYTHON) $$< -m $$(m_$(1)) -t $$(t_$(1)) -N $$(N_$(1)) -BLOCK $$(BLOCK) -mem_width $$(mem_width_$(1)) -mul_sec_BM $$(mul_sec_BM) -mul_sec_BM_step $$(mul_sec_BM_step) > $$@

$$(BUILD_DIR_SRC_$(1))/decryption.v: $$(DECRYPTION_SRC_PATH)/decryption.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call DECRYPTION_SRC_TEMPLATE,$(par))))


# Set the testbench source and data files of this module
DECRYPTION_TB_SRC = decryption_tb.v P.in poly_g.in error.in cipher.in

# Define comulated target for generated sources
ifeq (decryption,${TOPMODULE})
.PHONY: testbench
testbench: $(addprefix testbench-, $(PAR_SETS))
endif

# Define comulated target for generated sources
ifeq (decryption,${TOPMODULE})
.PHONY: sim
sim: $(addprefix sim-, $(PAR_SETS))
endif

DECRYPTION_TB =

#
# Define the testbench targets
#
define DECRYPTION_TB_TEMPLATE =

# Define all required targets to be included in the modules above
DECRYPTION_TB_$(1) = $(addprefix $$(BUILD_DIR_TB_$(1))/,$(DECRYPTION_TB_SRC))

# Collect all targets
DECRYPTION_TB += $$(DECRYPTION_TB_$(1))

# Define parameter-specific generated testbench building targets
ifeq (decryption,${TOPMODULE})
.PHONY: testbench-$(1)
testbench-$(1): $$(DECRYPTION_TB_$(1))
endif

$$(BUILD_DIR_TB_$(1)):
	mkdir -p $$@

$$(BUILD_DIR_TB_$(1))/decryption_tb.v: $$(DECRYPTION_SRC_PATH)/testbench/decryption_tb.v
	cp $$< $$@

$$(BUILD_DIR_TB_$(1))/P.in: $$(DECRYPTION_SRC_PATH)/testbench/gen_P.sage
	$(SAGE) $$^ $$(m_$(1)) > $$@

$$(BUILD_DIR_TB_$(1))/poly_g.in: $$(DECRYPTION_SRC_PATH)/testbench/gen_input.sage \
	$$(BUILD_DIR_TB_$(1))/P.in
	$(SAGE) $$< -t $$(t_$(1)) -m $$(m_$(1)) -n $$(N_$(1)) -s $$(seed_$(1)) \
	-P $$(BUILD_DIR_TB_$(1))/P.in \
	--error $$(BUILD_DIR_TB_$(1))/error.in \
	--cipher $$(BUILD_DIR_TB_$(1))/cipher.in \
	--polyg $$@

$$(BUILD_DIR_TB_$(1))/error.in: $$(BUILD_DIR_TB_$(1))/poly_g.in

$$(BUILD_DIR_TB_$(1))/cipher.in: $$(BUILD_DIR_TB_$(1))/error.in


# Define parameter-specific generated testbench run targets
ifeq (decryption,${TOPMODULE})
.PHONY: sim-$(1)
sim-$(1): run_decryption_$(1)_sim_iverilog
endif

# Build iverilog binary
# Note: The macro definition file must be at the very beginning.
$$(BUILD_DIR_TB_$(1))/decryption_sim_iverilog: testbench-$(1)\
	| $$(RESULTS_DIR)
	$(IVERILOG) -Wall -Wno-timescale \
	-Dm=$$(m_$(1)) -Dt=$$(t_$(1)) -DN=$$(N_$(1)) \
	-Dmem_width=$$(mem_width_$(1)) -DBLOCK=$$(BLOCK) \
	-Dmul_sec_BM=$$(mul_sec_BM) -Dmul_sec_BM_step=$$(mul_sec_BM_step) \
	-DFILE_MEM_CONSTS=$$(BUILD_DIR_SRC_$(1))/mem_consts \
	-DFILE_P=\"$$(BUILD_DIR_TB_$(1))/P.in\" \
	-DFILE_POLYG=\"$$(BUILD_DIR_TB_$(1))/poly_g.in\" \
	-DFILE_CIPHER=\"$$(BUILD_DIR_TB_$(1))/cipher.in\" \
	-DFILE_DATA_OUT=\"$$(BUILD_DIR_TB_$(1))/data.out\" \
	-DFILE_RE_ENC_OUT=\"$$(BUILD_DIR_TB_$(1))/re_encryption_res.out\" \
	-DFILE_DOUBLED_SYNDROME_OUT=\"$$(BUILD_DIR_TB_$(1))/doubled_syndrome.out\" \
	-DFILE_VCD=\"$$(BUILD_DIR_TB_$(1))/wave.vcd\" \
	-DFILE_CYCLES_PROFILE=\"$$(RESULTS_DIR)/cycles_profile_$(1).data\" \
	$$(BUILD_DIR_SRC_$(1))/clog2.v \
	$$(BUILD_DIR_TB_$(1))/decryption_tb.v \
	$$(filter-out $$(BUILD_DIR_SRC_$(1))/mem_consts $$(BUILD_DIR_SRC_$(1))/clog2.v,$$(sort $$(DECRYPTION_$(1)))) \
	-o $$@

# Run the iverilog binary
run_decryption_$(1)_sim_iverilog: $$(BUILD_DIR_TB_$(1))/decryption_sim_iverilog
	$$<
	@diff $$(BUILD_DIR_TB_$(1))/data.out $$(BUILD_DIR_TB_$(1))/error.in \
	&& echo "Test Passed!"

endef

$(foreach par, $(PAR_SETS), $(eval $(call DECRYPTION_TB_TEMPLATE,$(par))))

# Add the build directory as order-only-prerequisites to every source file target
$(DECRYPTION) $(DECRYPTION_TB): | $$(@D)

ifeq (decryption,${TOPMODULE})
$(RESULTS_DIR):
	mkdir -p $@
endif

# clean_decryption_src_$(1):
# 	rm -rf $$(DEC_SRC_$(1))

# clean_decryption_src: $(addprefix clean_, $(BUILD_DECRYPTION_SRC))

# Dump all defined variable
# $(foreach v,                                        \
#   $(filter-out $(VARS_OLD) VARS_OLD,$(sort $(.VARIABLES))), \
#   $(info > $(v) = $($(v))))
