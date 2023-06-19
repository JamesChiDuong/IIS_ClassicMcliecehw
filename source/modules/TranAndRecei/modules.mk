# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 

TRANANDRECEI_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Include the parameter set definitions
include $(TRANANDRECEI_SRC_PATH)/../../FPGA/parameters.mk

# Include toolset
include $(TRANANDRECEI_SRC_PATH)/../../FPGA/tools.mk

TOPMODULE ?= TranAndRecei

# List of the required submodules
TRANANDRECEI_SUBMODULES := BAUD_RATE_GENERATOR FULL_ADDER RECEIVER TRANSMITTER

# Build directory
BUILD_DIR ?= $(TRANANDRECEI_SRC_PATH)/build

# Directory for the performance results
RESULTS_DIR ?= $(BUILD_DIR)/results

.SECONDEXPANSION:
#
# Parameter-specific build subdirectories
#
ifndef BUILD_DIR_TEMPLATE
define BUILD_DIR_TEMPLATE =

#Parameter-specific build directory root

BUILD_DIR_$(1) = $$(BUILD_DIR)/$(1)/$$(TOPMODULE)

# Parameter-specific source, testbench, and KAT directory

BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/src
BUILD_DIR_TB_$(1) = $$(BUILD_DIR_$(1))/testbench_1
BUILD_DIR_SYNTH_$(1) = $$(BUILD_DIR_$(1))/synthesis

endef
$(foreach par, $(PAR_SETS), $(eval $(call BUILD_DIR_TEMPLATE,$(par))))
endif

#
# Configurations and options of the module
#
SLICED_PUBKEY_COLUMN_WIDTHS ?= 32 160

# Include makefiles for the submodules
#
include $(TRANANDRECEI_SRC_PATH)/baud_rate_generator/modules.mk
include $(TRANANDRECEI_SRC_PATH)/fullAdder/modules.mk
include $(TRANANDRECEI_SRC_PATH)/Receiver/modules.mk
include $(TRANANDRECEI_SRC_PATH)/Transmitter/modules.mk

# Add sources of the topmodule
TRANANDRECEI_SRC = TranAndRecei.v
# Add the sources of the submodules
TRANANDRECEI_SRC += $(foreach module,$(TRANANDRECEI_SUBMODULES),$($(module)_SRC))
# Define comulated target for source generation

.PHONY: sources
sources: $(addprefix sources-, $(PAR_SETS))
# Set of all sources
TRANANDRECEI =

# Define the parameter-specific sources and targets
define TRANANDRECEI_SRC_TEMPLATE =

# Define all required targets to be included in the modules above.
# The sort function filters double entries.
TRANANDRECEI_$(1) = $(sort $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(TRANANDRECEI_SRC)))

# Collect all sources
TRANANDRECEI += $$(TRANANDRECEI_$(1))

# Define parameter-specific sources targets
.PHONY: sources-$(1)
sources-$(1): $$(TRANANDRECEI_$(1))

# Make build directory for the sources


$$(BUILD_DIR_SRC_$(1)):
	mkdir -p $$@


# Sources generation
#
$$(BUILD_DIR_SRC_$(1))/%.v: $$(TRANANDRECEI_SRC_PATH)/%.v
	cp $$< $$@
endef

$(foreach par, $(PAR_SETS), $(eval $(call TRANANDRECEI_SRC_TEMPLATE,$(par))))

ifeq (TranAndRecei,${TOPMODULE})

#Add the build directory as order-only-prerequisites to every source file target
$(TRANANDRECEI): | $$(@D)

#
# Synthesis, Implement, Generate and Program targets and files
#
# Include vendor- and devices-specific definitions and recipes
include $(TRANANDRECEI_SRC_PATH)/../../FPGA/synthesis.mk

# Define the synthesis recipes for Xilinx devices
define TRANANDRECEI_SYNTH_TEMPLATE =

# Define required report files
TRANANDRECEI_RESULT_SYNTH_UTILIZATION_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_hierarchical_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_SYNTH_TIMING_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_summary_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_clocks_$(1)_$(2)_$(3).txt

# Perform the synthesis
# #TODO (MAKE versions < 3.8 do not support mutli-target rules)
$$(TRANANDRECEI_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)): $$(TRANANDRECEI_$(2)) $$(XILINX_RESOURCE_ANALYSIS_TCL) $$(XILINX_CONSTRAINTS_TIMING_$(1)) | $$(RESULTS_DIR)
	$$(VIVADO) \
	-nojournal \
	-log $$(RESULTS_DIR)/synthesis_$(1)_$(2)_$(3).log \
	-mode batch \
	-source $$(XILINX_RESOURCE_ANALYSIS_TCL) \
	-tclargs \
		"$$(TRANANDRECEI_$(2))" \
		$$(XILINX_CONSTRAINTS_TIMING_$(1)) \
		$$(XILINX_CONSTRAINTS_PIN_$(1))	\
		$(TOPMODULE) \
		$$(XILINX_FPGA_MODEL_ID_$(1)) \
		$$(TRANANDRECEI_RESULT_SYNTH_UTILIZATION_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_TIMING_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)) \
		"parameter_set=$$(id_$(2)) col_width=$(3) e_width=$(3) KEY_START_ADDR=0"

.PHONY: synthesis-$(1)-$(2)-$(3)

synthesis-$(1)-$(2)-$(3): $$(TRANANDRECEI_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3))

# Define parameter-specific synthesis results
SYNTH_$(2) ?=
SYNTH_$(2) += $$(TRANANDRECEI_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3))

endef

$(foreach model, $(XILINX_MODELS), \
	$(foreach par, $(PAR_SETS), \
		$(foreach width, $(SLICED_PUBKEY_COLUMN_WIDTHS), \
			$(eval $(call TRANANDRECEI_SYNTH_TEMPLATE,$(model),$(par),$(width))) \
		) \
	) \
)
define TRANANDRECEI_PROGRAM_TEMPLATE  =
# Define required report files
TRANANDRECEI_RESULT_PROGRAM_UTILIZATION_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_PROGRAM_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_hierarchical_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_PROGRAM_TIMING_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_PROGRAM_TIMING_SUMMARY_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_summary_$(1)_$(2)_$(3).txt
TRANANDRECEI_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_clocks_$(1)_$(2)_$(3).txt

# Perform the Program
# #TODO (MAKE versions < 3.8 do not support mutli-target rules)
$$(TRANANDRECEI_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3)): $$(TRANANDRECEI_$(2)) $$(XILINX_RESOURCE_PROGRAM_TCL) $$(XILINX_CONSTRAINTS_TIMING_$(1)) | $$(RESULTS_DIR)
	$$(VIVADO) \
	-nojournal \
	-log $$(RESULTS_DIR)/program_$(1)_$(2)_$(3).log \
	-mode batch \
	-source $$(XILINX_RESOURCE_PROGRAM_TCL) \
	-tclargs \
		"$$(TRANANDRECEI_$(2))" \
		$$(XILINX_CONSTRAINTS_TIMING_$(1)) \
		$$(XILINX_CONSTRAINTS_PIN_$(1))	\
		$(TOPMODULE) \
		$$(XILINX_FPGA_MODEL_ID_$(1)) \
		$$(TRANANDRECEI_RESULT_SYNTH_UTILIZATION_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_TIMING_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)_$(3)) \
		$$(TRANANDRECEI_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)) \
		"parameter_set=$$(id_$(2)) col_width=$(3) e_width=$(3) KEY_START_ADDR=0"

.PHONY: program-$(1)

program-$(1): $$(TRANANDRECEI_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3))

# Define parameter-specific synthesis results
PROGRAM_$(2) ?=
PROGRAM_$(2) += $$(TRANANDRECEI_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3))
endef

$(foreach par, $(PAR_SETS), $(eval $(call TRANANDRECEI_PROGRAM_TEMPLATE,$(par))))
# Define synthesis and results targets
define TRANANDRECEI_RESULTS_TEMPLATE =

.PHONY: synthesis-$(1)
synthesis-$(1): $$(SYNTH_$(1))
endef

$(foreach par, $(PAR_SETS), $(eval $(call TRANANDRECEI_RESULTS_TEMPLATE,$(par))))
# Define comulated target for the synthesis
.PHONY: synthesis
synthesis: $(addprefix synthesis-, $(PAR_SETS))

.PHONY: program
program: $(addprefix program-, $(PAR_SETS))

# Define comulated target for all performance results
.PHONY: results
results: $(addprefix results-, $(PAR_SETS))
# Result directory
$(RESULTS_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(TOPMODULE).bit
	rm -rf .txt
endif