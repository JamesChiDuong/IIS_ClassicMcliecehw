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

# Decapsulation module with an upstream FieldOrdering module.

DECAPSULATION_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export ROOT_PATH
# Include the parameter set definitions
include $(DECAPSULATION_SRC_PATH)/../FPGA/parameters.mk

# Include toolset
include $(DECAPSULATION_SRC_PATH)/../FPGA/tools.mk

# Name of the design's topmodule
TOPMODULE ?= decapsulation

# List of the required submodules
DECAPSULATION_SUBMODULES := DECRYPTION SHAKE256 MEMORY_SINGLE MEMORY_DUAL FIELD_ORDERING BAUD_RATE_GENERATOR RECEIVER TRANSMITTER

#
# Directory and path definitions
#
# Build directory
BUILD_DIR ?= $(DECAPSULATION_SRC_PATH)/build
# include $(BUILD_DIR)/.config.mk
# Directory pointing to the known answer tests
KAT_DIR ?= $(ROOT_PATH)/host/kat/kat_generate
# Directory for the performance results
RESULTS_DIR ?= $(BUILD_DIR)/results

# Source path for the common used modules
COMMON_SRC_PATH ?= $(ROOT_PATH)/modules/common
# Source path for the KAT generation script
KATGEN_SRC_PATH ?= $(ROOT_PATH)/host/kat

RTL_SRC_PATH 	?= $(ROOT_PATH)/platform/rtl

.SECONDEXPANSION:

#
# Parameter-specific build subdirectories
#
ifndef BUILD_DIR_TEMPLATE
define BUILD_DIR_TEMPLATE =

# Parameter-specific build directory root
# BUILD_DIR_$(1) = $$(BUILD_DIR)
# # Parameter-specific source, testbench, and KAT directory
# BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/verilog
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
# Include makefiles for the submodules and KAT generation
#
include $(DECAPSULATION_SRC_PATH)/decryption/module.mk
include $(COMMON_SRC_PATH)/shake256/module.mk
include $(COMMON_SRC_PATH)/field_ordering/module.mk
include $(COMMON_SRC_PATH)/memory/module.mk
include $(KATGEN_SRC_PATH)/Makefile
include $(RTL_SRC_PATH)/rtl.mk
#
# Sources definitions
export SIMU_DIR
export TOPMODULES
export TOPMODULES_SIMU


export CLOCK_FPGA
#

# Set the source files of this module
DECAPSULATION_SRC = decap_with_support.v decap.v
DECAPSULATION_SRC += rearrange_vector.v

# Add the sources of the submodules
DECAPSULATION_SRC += $(foreach module,$(DECAPSULATION_SUBMODULES),$($(module)_SRC))

# Define comulated target for generated sources
.PHONY: sources
sources: $(addprefix sources-, $(PAR_SETS))

# Set of all sources
DECAPSULATION =


# Define the parameter-specific sources and targets
define DECAPSULATION_SRC_TEMPLATE =

# Define all required targets to be included in the modules above.
# The sort function filters double entries.
DECAPSULATION_$(1) = $(sort $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(DECAPSULATION_SRC)))

# Collect all targets
DECAPSULATION += $$(DECAPSULATION_$(1))

# Define parameter-specific sources targets
.PHONY: sources-$(1)
sources-$(1): $$(DECAPSULATION_$(1))

# # Make build directory for the sources
# $$(BUILD_DIR_SRC_$(1)):
# 	mkdir -p $$@

#
# Sources generation
#
$$(BUILD_DIR_SRC_$(1))/decap_with_support.v: $$(DECAPSULATION_SRC_PATH)/decap_with_support.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/decap.v: $$(DECAPSULATION_SRC_PATH)/decap.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/rearrange_vector.v: $$(COMMON_SRC_PATH)/rearrange_vector.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call DECAPSULATION_SRC_TEMPLATE,$(par))))


ifeq (decapsulation,${TOPMODULE})
#
# Testbench sources definitions
#

# Set the testbench sources
DECAPSULATION_TB_SRC = $(TOPMODULES_SIMU).v
# DECAPSULATION_TB_SRC = decap_tb.v

# Define the comulated target for testbench sources generation
.PHONY: testbench
testbench: $(addprefix testbench-, $(PAR_SETS))

# Set of all testbench sources
DECAPSULATION_TB =


# Define the parameter-specific testbench targets
define DECAPSULATION_TB_TEMPLATE =

# Define all required targets to be included in the modules above.
DECAPSULATION_TB_$(1) = $(addprefix $$(BUILD_DIR_TB_$(1))/,$(DECAPSULATION_TB_SRC))

# Collect all testbench targets
DECAPSULATION_TB += $$(DECAPSULATION_TB_$(1))

# Define parameter-specific testbench targets
.PHONY: testbench-$(1)
testbench-$(1): sources-$(1) $$(DECAPSULATION_TB_$(1))

# $$(BUILD_DIR_TB_$(1)):
# 	mkdir -p $$@

#
# Sources generation
#
$$(BUILD_DIR_TB_$(1))/%.v: $$(DECAPSULATION_SRC_PATH)/testbench/%.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call DECAPSULATION_TB_TEMPLATE,$(par))))

#
# Simulation targets and files
#

# Define Verilator-specific testbench source
DECAPSULATION_VERILATOR_TB_SRC = $(SIMU_DIR)/cpp/$(TOPMODULES)/$(TOPMODULES_SIMU).cpp
DECAPSULATION_VERILATOR_UARTSIM_SRC = $(SIMU_DIR)/cpp/$(TOPMODULES)/uartsim.cpp
# Define comulated target for the simulation runs und results generation
.PHONY: sim
sim: $(addprefix sim-, $(PAR_SETS))

# Parameter-specific simulator definitions and targets
define DECAPSULATION_SIM_TEMPLATE =

# Required KAT files for decapsulation
DECAPSULATION_KAT_$(1) = \
	$$(addprefix $$(KAT_DIR_$(1))/, \
	$(KAT_FILE_POLY_G))
	# $(KAT_FILE_CIPHER_0) \
	# $(KAT_FILE_CIPHER_1) \
	# $(KAT_FILE_DELTA_PRIME) \
	# $(KAT_FILE_K) \
	# $(KAT_FILE_P) \

# Set of all files to perform the simulation
DECAPSULATION_SIM_$(1) = \
	$$(DECAPSULATION_VERILATOR_TB_SRC) \
	$$(DECAPSULATION_TB_$(1)) \
	$$(DECAPSULATION_$(1)) \
	$$(DECAPSULATION_KAT_$(1))

# Simulation binaries
DECAPSULATION_VERILATOR_BIN_$(1) = $$(RESULTS_DIR)/$(TOPMODULES_SIMU).bin

# Simulation performance files
DECAPSULATION_RESULT_TB_$(1) = $$(RESULTS_DIR)/cycles_profile_$(1)_$(TOPMODULE).data

# Define parameter-specific simulation results
SIM_$(1) ?=
SIM_$(1) += $$(DECAPSULATION_RESULT_TB_$(1))

# Simulation binary target
$$(DECAPSULATION_VERILATOR_BIN_$(1)): $$(DECAPSULATION_SIM_$(1)) | $$(RESULTS_DIR)
	$(VERILATOR) \
	--unroll-count 1024 \
	-Wno-context -Wno-style -Wno-lint -Wno-fatal \
	--timescale-override 1ps/1ps \
	--trace \
	--Mdir $$(BUILD_DIR_TB_$(1))/obj_dir \
	--top-module $$(TOPMODULES_SIMU) \
	-Gparameter_set=$$(id_$(1)) \
	-DFILE_MEM_CONSTS=\"$$(BUILD_DIR_SRC_$(1))/mem_consts\" \
	-DFILE_C0=\"$$(KAT_DIR_$(1))/$(KAT_FILE_CIPHER_0)\" \
	-DFILE_C1=\"$$(KAT_DIR_$(1))/$(KAT_FILE_CIPHER_1)\" \
	-DFILE_P=\"$$(KAT_DIR_$(1))/$(KAT_FILE_P)\" \
	-DFILE_DELTA=\"$$(KAT_DIR_$(1))/$(KAT_FILE_DELTA_PRIME)\" \
	-DFILE_POLYG=\"$$(KAT_DIR_$(1))/$(KAT_FILE_POLY_G)\" \
	-DFILE_ERROR_OUT=\"$$(BUILD_DIR_TB_$(1))/error.out\" \
	-DFILE_RE_ENC_OUT=\"$$(BUILD_DIR_TB_$(1))/re_encryption_res.out\" \
	-DFILE_DOUBLED_SYNDROME_OUT=\"$$(BUILD_DIR_TB_$(1))/doubled_syndrome.out\" \
	-DFILE_K_OUT=\"$$(RESULTS_DIR)/K.out\" \
	-DFILE_VCD=\"$$(RESULTS_DIR)/wave.vcd\" \
	-DFILE_CYCLES_PROFILE=\"$$(DECAPSULATION_RESULT_TB_$(1))\" \
	-GBAUD_RATE=$(BAUD_RATE) \
	-GCLOCK_FPGA=$(CLOCK_FPGA)\
	-DCLOCK_FPGA=$(CLOCK_FPGA)\
	-DBAUD_RATE=$(BAUD_RATE)\
	-I$$(BUILD_DIR_SRC_$(1)) \
	-I$$(BUILD_DIR_TB_$(1)) \
	--cc \
	$$(BUILD_DIR_SRC_$(1))/clog2.v \
	$$(DECAPSULATION_TB_$(1)) \
	$$(filter-out $$(BUILD_DIR_SRC_$(1))/mem_consts $$(BUILD_DIR_SRC_$(1))/clog2.v,$$(DECAPSULATION_$(1))) \
	--exe  $$< $$(DECAPSULATION_VERILATOR_UARTSIM_SRC)\
	--build \
	-j 8 \
	--threads 1 \
	--x-initial 0 \
	-o $$@

# Perform the simulation, record the performance data, and check the outcome.
$$(DECAPSULATION_RESULT_TB_$(1)): $$(DECAPSULATION_VERILATOR_BIN_$(1)) $$(DECAPSULATION_KAT_$(1))
	$$<
	sed -i -e ':a' -e 'N;s/\n//;ba' $$(RESULTS_DIR)/K.out
	diff $$(RESULTS_DIR)/K.out $$(KAT_DIR_$(1))/$(KAT_FILE_K) \
	&& echo "[$(1)-decapsulation] Test Passed!"


# Define parameter-specific generated testbench run targets
.PHONY: sim-$(1)
sim-$(1): $$(SIM_$(1))

endef

$(foreach par, $(PAR_SETS), $(eval $(call DECAPSULATION_SIM_TEMPLATE,$(par))))

# Define comulated target for generated sources
.PHONY: sim
sim: $(addprefix sim-, $(PAR_SETS))


#
# Synthesis targets and files
#
# Include vendor- and devices-specific definitions and recipes
include $(DECAPSULATION_SRC_PATH)/../FPGA/synthesis.mk

# Define the synthesis recipes for Xilinx devices
define DECAPSULATION_SYNTH_TEMPLATE =

# Define required report files
DECAPSULATION_RESULT_SYNTH_UTILIZATION_$(1)_$(2) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_$(1)_$(2).txt
DECAPSULATION_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_hierarchical_$(1)_$(2).txt
DECAPSULATION_RESULT_SYNTH_TIMING_$(1)_$(2) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_$(1)_$(2).txt
DECAPSULATION_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_summary_$(1)_$(2).txt
DECAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2) = $$(RESULTS_DIR)/$(TOPMODULE)_clocks_$(1)_$(2).txt

# # Set of all files to perform the synthesis
DECAPSULATION_SYNTH_$(2) = \
	$$(DECAPSULATION_TB_$(1)) \
	$$(DECAPSULATION_$(1))

# Perform the synthesis
# #TODO (MAKE versions < 3.8 do not support mutli-target rules)
$$(DECAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2)): $$(DECAPSULATION_$(2)) $$(DECAPSULATION_TB_$(2)) $$(XILINX_RESOURCE_ANALYSIS_TCL) $$(XILINX_CONSTRAINTS_TIMING_$(1)) | $(RESULTS_DIR)
	$$(VIVADO) \
	-nojournal \
	-log $$(RESULTS_DIR)/synthesis_$(1)_$(2).log \
	-mode batch \
	-source $$(XILINX_RESOURCE_ANALYSIS_TCL) \
	-tclargs \
		"$$(DECAPSULATION_$(2)) + $$(DECAPSULATION_TB_$(2))" \
		$$(XILINX_CONSTRAINTS_TIMING_$(1)) \
		$$(XILINX_CONSTRAINTS_PIN_$(1))	\
		$(TOPMODULES_SIMU) \
		$$(XILINX_FPGA_MODEL_ID_$(1)) \
		$$(DECAPSULATION_RESULT_SYNTH_UTILIZATION_$(1)_$(2)) \
		$$(DECAPSULATION_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)) \
		$$(DECAPSULATION_RESULT_SYNTH_TIMING_$(1)_$(2)) \
		$$(DECAPSULATION_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)) \
		$$(DECAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2)) \
		"parameter_set=$$(id_$(2)) KEY_START_ADDR=0 BAUD_RATE=$(BAUD_RATE) CLOCK_FPGA=$(CLOCK_FPGA)" \
		FILE_MEM_CONSTS=$$(BUILD_DIR_SRC_$(2))/mem_consts


.PHONY: synthesis-$(1)-$(2)

synthesis-$(1)-$(2): $$(DECAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2))

# Define parameter-specific synthesis results
SYNTH_$(2) ?=
SYNTH_$(2) += $$(DECAPSULATION_RESULT_SYNTH_CLOCKS_$(1)_$(2))

endef

$(foreach model, $(XILINX_MODELS), \
	$(foreach par, $(PAR_SETS), \
		$(eval $(call DECAPSULATION_SYNTH_TEMPLATE,$(model),$(par))) \
	) \
)

# Define synthesis and results targets
define DECAPSULATION_RESULTS_TEMPLATE =

.PHONY: synthesis-$(1)
synthesis-$(1): $$(SYNTH_$(1))

.PHONY: results-$(1)
results-$(1): $$(SYNTH_$(1))

endef

$(foreach par, $(PAR_SETS), $(eval $(call DECAPSULATION_RESULTS_TEMPLATE,$(par))))


# Define comulated target for the synthesis
.PHONY: synthesis
synthesis: $(addprefix synthesis-, $(PAR_SETS))

# Define comulated target for all performance results
.PHONY: results
results: $(addprefix results-, $(PAR_SETS))

# Add the build directory as order-only-prerequisites to every source file target
$(DECAPSULATION) $(DECAPSULATION_TB): | $$(@D)

$(RESULTS_DIR):
	mkdir -p $@

clean-decap:
	rm -rf $(BUILD_DIR)

endif
