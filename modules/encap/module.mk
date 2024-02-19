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

# Encapsulation Module

ENCAPSULATION_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include $(ENCAPSULATION_SRC_PATH)/../FPGA/parameters.mk

# Include toolset
include $(ENCAPSULATION_SRC_PATH)/../FPGA/tools.mk

# Name of the design's topmodule
TOPMODULE ?= encapsulation

# List of the required submodules
ENCAPSULATION_SUBMODULES := ENCRYPTION FIXED_WEIGHT SHAKE256 MEMORY_SINGLE MEMORY_DUAL LOG2 BAUD_RATE_GENERATOR RECEIVER TRANSMITTER

#
# Directory and path definitions
#
# Build directory
BUILD_DIR ?= $(ENCAPSULATION_SRC_PATH)/build
# Directory pointing to the known answer tests
KAT_DIR ?= $(ROOT_PATH)/host/kat/kat_generate
# Directory for the performance results
RESULTS_DIR ?= $(BUILD_DIR)/results

# Source path for the common used modules
COMMON_SRC_PATH ?= $(ENCAPSULATION_SRC_PATH)/../common
# Source path for the KAT generation script
KATGEN_SRC_PATH ?= $(ROOT_PATH)/host/kat

RTL_SRC_PATH 	?= $(ROOT_PATH)/platform/rtl
MCELIECE_KATGEN_SAGE ?= $(KATGEN_SRC_PATH)/kat.sage
.SECONDEXPANSION:

#
# Parameter-specific build subdirectories
#
ifndef BUILD_DIR_TEMPLATE
define BUILD_DIR_TEMPLATE =

# Parameter-specific build directory root
# BUILD_DIR_$(1) = $$(BUILD_DIR)/$(1)/$$(TOPMODULE)
# # Parameter-specific source, testbench, and KAT directory
# BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/src
# BUILD_DIR_TB_$(1) = $$(BUILD_DIR_$(1))/testbench
# BUILD_DIR_SYNTH_$(1) = $$(BUILD_DIR_$(1))/synthesis
# BUILD_DIR_KAT_$(1) = $$(KAT_DIR/$(1))
ifeq ($(TARGET),sim)
BUILD_DIR_$(1) = $$(BUILD_DIR)
BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/verilog
BUILD_DIR_TB_$(1) = $$(BUILD_DIR_$(1))/verilog
BUILD_DIR_KAT_$(1) = $$(KAT_DIR/$(1))
else
#Parameter-specific build directory root

BUILD_DIR_$(1) = $$(BUILD_DIR)/$(1)/$$(TOPMODULE)

# Parameter-specific source, testbench, and KAT directory

BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/src
BUILD_DIR_TB_$(1) = $$(BUILD_DIR_$(1))/src
endif
endef

$(foreach par, $(PAR_SETS), $(eval $(call BUILD_DIR_TEMPLATE,$(par))))

endif

#
# Configurations and options of the module
#
SLICED_PUBKEY_COLUMN_WIDTHS ?= 32 160

#
# Include makefiles for the submodules and KAT generation
#


include $(ENCAPSULATION_SRC_PATH)/encryption/module.mk
include $(ENCAPSULATION_SRC_PATH)/fixed_weight/module.mk
include $(COMMON_SRC_PATH)/memory/module.mk
include $(COMMON_SRC_PATH)/shake256/module.mk
include $(COMMON_SRC_PATH)/math/module.mk
include $(KATGEN_SRC_PATH)/Makefile

##
export SIMU_DIR
export TOPMODULES
export TOPMODULES_SIMU


export CLOCK_FPGA
include $(RTL_SRC_PATH)/rtl.mk
#
# Sources definitions
#

# Add sources of the topmodule
ENCAPSULATION_SRC = encap.v
ENCAPSULATION_SRC += rearrange_vector.v

# Add the sources of the submodules
ENCAPSULATION_SRC += $(foreach module,$(ENCAPSULATION_SUBMODULES),$($(module)_SRC))

# Define comulated target for source generation
.PHONY: sources
sources: $(addprefix sources-, $(PAR_SETS))

# Set of all sources
ENCAPSULATION =


# Define the parameter-specific sources and targets
define ENCAPSULATION_SRC_TEMPLATE =

# Define all required targets to be included in the modules above.
# The sort function filters double entries.
ENCAPSULATION_$(1) = $(sort $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(ENCAPSULATION_SRC)))

# Collect all sources
ENCAPSULATION += $$(ENCAPSULATION_$(1))

# Define parameter-specific sources targets
.PHONY: sources-$(1)
sources-$(1): $$(ENCAPSULATION_$(1))

# Make build directory for the sources
$$(BUILD_DIR_SRC_$(1)):
	mkdir -p $$@

#
# Sources generation
#
$$(BUILD_DIR_SRC_$(1))/%.v: $$(ENCAPSULATION_SRC_PATH)/%.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/rearrange_vector.v: $$(COMMON_SRC_PATH)/rearrange_vector.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call ENCAPSULATION_SRC_TEMPLATE,$(par))))


ifeq (encapsulation,${TOPMODULE})
#
# Testbench sources definitions
#

# Set the testbench sources
ENCAPSULATION_TB_SRC = $(TOPMODULES_SIMU).v

# Define the comulated target for testbench sources generation
.PHONY: testbench
testbench: $(addprefix testbench-, $(PAR_SETS))

# Set of all testbench sources
ENCAPSULATION_TB =


# Define the parameter-specific testbench targets
define ENCAPSULATION_TB_TEMPLATE =

# Define all required targets to be included in the modules above.
ENCAPSULATION_TB_$(1) = $(addprefix $$(BUILD_DIR_TB_$(1))/,$(ENCAPSULATION_TB_SRC))

# Collect all testbench targets
ENCAPSULATION_TB += $$(ENCAPSULATION_TB_$(1))

# Define parameter-specific testbench targets
.PHONY: testbench-$(1)
testbench-$(1): $$(ENCAPSULATION_$(1)) $$(ENCAPSULATION_TB_$(1))

# Make build directory for the testbench sources
$$(BUILD_DIR_TB_$(1)):
	mkdir -p $$@

#
# Sources generation
#
$$(BUILD_DIR_TB_$(1))/%.v: $$(ENCAPSULATION_SRC_PATH)/testbench/%.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call ENCAPSULATION_TB_TEMPLATE,$(par))))


# Add the build directory as order-only-prerequisites to every source file target
$(ENCAPSULATION) $(ENCAPSULATION_TB): | $$(@D)


#
# Simulation targets and files
#

# Define Verilator-specific testbench source
ENCAPSULATION_VERILATOR_TB_SRC = $(SIMU_DIR)/cpp/$(TOPMODULES)/$(TOPMODULES_SIMU).cpp
ENCAPSULATION_VERILATOR_UARTSIM_SRC = $(SIMU_DIR)/cpp/$(TOPMODULES)/uartsim.cpp
#ENCAPSULATION_VERILATOR_UARTSIM_SRC += $(SIMU_DIR)/cpp/uartsim.h
# Define comulated target for the simulation runs und results generation
.PHONY: sim
sim: $(addprefix sim-, $(PAR_SETS))


# Parameter-specific simulator definitions for multiple public key slice widths
define ENCAPSULATION_SIM_SLICES_TEMPLATE =

# Define public key name for specific slice width
KAT_FILE_PUBKEY_$(2) = $(basename $(KAT_FILE_PUBKEY))_$(2)$(suffix $(KAT_FILE_PUBKEY))

# Required KAT files for encapsulation
ENCAPSULATION_KAT_$(1) = \
	$$(KAT_DIR_$(1))/$(KAT_FILE_SEED) \
	$$(KAT_DIR_$(1))/$$(KAT_FILE_PUBKEY_$(2))

# Set of all files to perform the simulation
ENCAPSULATION_SIM_$(1)_$(2) = \
	$$(ENCAPSULATION_VERILATOR_TB_SRC) \
	$$(ENCAPSULATION_TB_$(1)) \
	$$(ENCAPSULATION_$(1)) \
	$$(ENCAPSULATION_KAT_$(1))

# Simulation binaries
ENCAPSULATION_VERILATOR_BIN_$(1)_$(2) = $$(RESULTS_DIR)/encap_tb_$(2).bin

# Simulation performance files
ENCAPSULATION_RESULT_TB_$(1)_$(2) = $$(RESULTS_DIR)/cycles_profile_$(1)_$(TOPMODULE)_$(2).data

# Define parameter-specific simulation results
SIM_$(1) ?=
SIM_$(1) += $$(ENCAPSULATION_RESULT_TB_$(1)_$(2))

# Simulation binary target
$$(ENCAPSULATION_VERILATOR_BIN_$(1)_$(2)): $$(ENCAPSULATION_SIM_$(1)_$(2)) | $$(RESULTS_DIR)
	$(VERILATOR) \
	--unroll-count 1024 \
	-Wno-fatal  \
	--timescale-override 1ps/1ps \
	--trace \
	--Mdir $$(BUILD_DIR_TB_$(1))/obj_dir_$(2) \
	--top-module $(TOPMODULES_SIMU) \
	-Gparameter_set=$$(id_$(1)) \
	-Gcol_width=$(2) \
	-Ge_width=$(2) \
	-GKEY_START_ADDR=0 \
	-DFILE_MEM_SEED=\"$$(KAT_DIR_$(1))/$(KAT_FILE_SEED)\" \
	-DFILE_PK_SLICED=\"$$(KAT_DIR_$(1))/$$(KAT_FILE_PUBKEY_$(2))\" \
	-DFILE_CIPHER0_OUT=\"$$(RESULTS_DIR)/cipher_0_$(2).out\" \
	-DFILE_CIPHER1_OUT=\"$$(RESULTS_DIR)/cipher_1_$(2).out\" \
	-DFILE_K_OUT=\"$$(RESULTS_DIR)/K_$(2).out\" \
	-DFILE_ERROR_OUT=\"$$(RESULTS_DIR)/error_$(2).out\" \
	-DFILE_VCD=\"$$(RESULTS_DIR)/wave_$(2).vcd\" \
	-DFILE_CYCLES_PROFILE=\"$$(ENCAPSULATION_RESULT_TB_$(1)_$(2))\" \
	-GBAUD_RATE=$(BAUD_RATE) \
	-GCLOCK_FPGA=$(CLOCK_FPGA)\
	-DCLOCK_FPGA=$(CLOCK_FPGA)\
	-DBAUD_RATE=$(BAUD_RATE)\
	-I$$(BUILD_DIR_SRC_$(1)) \
	-I$$(BUILD_DIR_TB_$(1)) \
	--cc \
	$$(BUILD_DIR_SRC_$(1))/clog2.v \
	$$(ENCAPSULATION_TB_$(1)) \
	$$(filter-out $$(BUILD_DIR_SRC_$(1))/clog2.v,$$(ENCAPSULATION_$(1)))\
	--exe $$< $$(ENCAPSULATION_VERILATOR_UARTSIM_SRC) \
	--build \
	-j 8 \
	--threads 1 \
	--x-initial 0 \
	-o $$@


# Perform the simulation, record the performance data, and check the outcome.

$$(ENCAPSULATION_RESULT_TB_$(1)_$(2)): $$(ENCAPSULATION_VERILATOR_BIN_$(1)_$(2))
	$$<
	$(SAGE) $(MCELIECE_KATGEN_SAGE) \
	--check-encaps \
	--kat-path $$(KAT_DIR_$(1)) \
	--pars $(1) \
	--sessionkey $$(RESULTS_DIR)/K_$(2).out \
	--cipher $$(RESULTS_DIR)/cipher_0_$(2).out $$(RESULTS_DIR)/cipher_1_$(2).out \
	&& echo "[$(1)-$(2)-encapsulation] Test Passed!"
endef

$(foreach par, $(PAR_SETS), \
	$(foreach width, $(SLICED_PUBKEY_COLUMN_WIDTHS), \
		$(eval $(call ENCAPSULATION_SIM_SLICES_TEMPLATE,$(par),$(width)))))


# Define parameter-specific simualtion targets
define ENCAPSULATION_SIM_TARGETS_TEMPLATE =

.PHONY: sim-$(1)
sim-$(1): $$(SIM_$(1))

endef

$(foreach par, $(PAR_SETS), $(eval $(call ENCAPSULATION_SIM_TARGETS_TEMPLATE,$(par))))


#
# Synthesis targets and files
#
# Include vendor- and devices-specific definitions and recipes
include $(ENCAPSULATION_SRC_PATH)/../FPGA/synthesis.mk

# Define the synthesis recipes for Xilinx devices
define ENCAPSULATION_SYNTH_TEMPLATE =

# Define required report files
ENCAPSULATION_RESULT_SYNTH_UTILIZATION_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_$(1)_$(2)_$(3).txt
ENCAPSULATION_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_hierarchical_$(1)_$(2)_$(3).txt
ENCAPSULATION_RESULT_SYNTH_TIMING_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_$(1)_$(2)_$(3).txt
ENCAPSULATION_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_summary_$(1)_$(2)_$(3).txt
ENCAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_clocks_$(1)_$(2)_$(3).txt

# # Set of all files to perform the synthesis
ENCAPSULATION_SYNTH_$(2) = \
	$$(ENCAPSULATION_TB_$(2)) \
	$$(ENCAPSULATION_$(2))

# Perform the synthesis
# #TODO (MAKE versions < 3.8 do not support mutli-target rules)
$$(ENCAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)): $$(ENCAPSULATION_SYNTH_$(2)) $$(ENCAPSULATION_TB_$(2)) $$(XILINX_RESOURCE_ANALYSIS_TCL) $$(XILINX_CONSTRAINTS_TIMING_$(1)) $$(XILINX_CONSTRAINTS_TIMING_$(1))| $$(RESULTS_DIR)
	$$(VIVADO) \
	-nojournal \
	-log $$(RESULTS_DIR)/synthesis_$(1)_$(2)_$(3).log \
	-mode batch \
	-source $$(XILINX_RESOURCE_ANALYSIS_TCL) \
	-tclargs \
		"$$(ENCAPSULATION_SYNTH_$(2))" \
		$$(XILINX_CONSTRAINTS_TIMING_$(1)) \
		$$(XILINX_CONSTRAINTS_PIN_$(1))	\
		$(TOPMODULES_SIMU) \
		$$(XILINX_FPGA_MODEL_ID_$(1)) \
		$$(ENCAPSULATION_RESULT_SYNTH_UTILIZATION_$(1)_$(2)_$(3)) \
		$$(ENCAPSULATION_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3)) \
		$$(ENCAPSULATION_RESULT_SYNTH_TIMING_$(1)_$(2)_$(3)) \
		$$(ENCAPSULATION_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)_$(3)) \
		$$(ENCAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)) \
		"parameter_set=$$(id_$(2)) col_width=$(3) e_width=$(3) KEY_START_ADDR=0 BAUD_RATE=$(BAUD_RATE) CLOCK_FPGA=$(CLOCK_FPGA)"

.PHONY: synthesis-$(1)-$(2)-$(3)

synthesis-$(1)-$(2)-$(3): $$(ENCAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)) 

# Define parameter-specific synthesis results
SYNTH_$(2) ?=
SYNTH_$(2) += $$(ENCAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3))

endef

$(foreach model, $(XILINX_MODELS), \
	$(foreach par, $(PAR_SETS), \
		$(foreach width, $(SLICED_PUBKEY_COLUMN_WIDTHS), \
			$(eval $(call ENCAPSULATION_SYNTH_TEMPLATE,$(model),$(par),$(width))) \
		) \
	) \
)

# Define synthesis and results targets
define ENCAPSULATION_RESULTS_TEMPLATE =

.PHONY: synthesis-$(1)
synthesis-$(1): $$(SYNTH_$(1))

.PHONY: results-$(1)
results-$(1): $$(SYNTH_$(1))

endef

$(foreach par, $(PAR_SETS), $(eval $(call ENCAPSULATION_RESULTS_TEMPLATE,$(par))))


# Define comulated target for the synthesis
.PHONY: synthesis
synthesis: $(addprefix synthesis-, $(PAR_SETS))

# Define comulated target for all performance results
.PHONY: results
results: $(addprefix results-, $(PAR_SETS))

# Result directory
$(RESULTS_DIR):
	mkdir -p $@


#
# Cleaning targets
#

clean-encap:
	rm -rf $(BUILD_DIR)

endif
