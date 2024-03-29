# Authors: James <chiduong1312@gmail.com>
# 

MODULESTOP_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Include the parameter set definitions
include $(MODULESTOP_SRC_PATH)/FPGA/parameters.mk

# Include toolset
include $(MODULESTOP_SRC_PATH)/FPGA/tools.mk

#-----Define TOP_MODULES----------#
export TOPMODULES
export TOPMODULES_SIMU
export ROOT_PATH
export BAUD_RATE
export CLOCK_FPGA
# TOPMODULE ?= $(TOPMODULES)
# TOPMODULE_CHECK ?= $(TOPMODULES)

TOPMODULE ?= $(TOPMODULES)
TOPMODULE_CHECK ?=$(TOPMODULES)
#build directory
BUILD_DIR ?= $(MODULESTOP_SRC_PATH)/build
KAT_DIR ?= $(BUILD_DIR)/kat
# Directory for the performance results
RESULTS_DIR ?= $(BUILD_DIR)/results
# Source path for the common used modules
COMMON_SRC_PATH ?= $(MODULESTOP_SRC_PATH)/common
KATGEN_SRC_PATH ?= $(ROOT_PATH)/host/kat
TB_SRC_PATH ?= $(MODULESTOP_SRC_PATH)/$(TOPMODULES)/testbench
.SECONDEXPANSION:
#
# Parameter-specific build subdirectories
#
ifndef BUILD_DIR_TEMPLATE
define BUILD_DIR_TEMPLATE =
ifeq ($(TARGET),sim)
BUILD_DIR_$(1) = $$(BUILD_DIR)
BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/verilog
# BUILD_DIR_TB_$(1) = $$(BUILD_DIR_$(1))/verilog
BUILD_DIR_KAT_$(1) = $$(KAT_DIR/$(1))
else
#Parameter-specific build directory root

BUILD_DIR_$(1) = $$(BUILD_DIR)/$(1)/$$(TOPMODULE)

# Parameter-specific source, testbench, and KAT directory

BUILD_DIR_SRC_$(1) = $$(BUILD_DIR_$(1))/src
endif

endef
$(foreach par, $(PAR_SETS), $(eval $(call BUILD_DIR_TEMPLATE,$(par))))
endif

#
# Configurations and options of the module
#
SLICED_PUBKEY_COLUMN_WIDTHS ?= 32

# Include makefiles for the submodules
#
# Export ROOT_PATH from FPGA.mk
include platform/rtl/rtl.mk
include modules/encap/modules.mk
include $(COMMON_SRC_PATH)/modules.mk


TOPMODULES_SRC_PATH := $(MODULESTOP_SRC_PATH)/$(TOPMODULES)

ADDITIONAL_MODULE ?= rearrange_vector
#-----Define SUBMODULES------------#
#*****Define UART SUB_MODULES******#
UART_SUBMODULES := BAUD_RATE_GENERATOR RECEIVER TRANSMITTER
SUBMODULES = ENCRYPTION FIXED_WEIGHT SHAKE256 MEMORY_SINGLE MEMORY_DUAL LOG2

MODULESTOP_SUBMODULES = $(UART_SUBMODULES) + $(SUBMODULES)
# List of the required submodules

# Add sources of the topmodule
MODULESTOP_SRC = $(TOPMODULES).v
MODULESTOP_SRC += $(ADDITIONAL_MODULE).v
MODULESTOP_SRC +=  $(TOPMODULES_SIMU).v


# Add the sources of the submodules
MODULESTOP_UART_SRC = $(foreach module,$(UART_SUBMODULES),$($(module)_SRC))
MODULESTOP_SRC += $(foreach module,$(SUBMODULES),$($(module)_SRC))

# Define comulated target for source generation

.PHONY: sim
sim: $(addprefix sim-, $(PAR_SETS))
# .PHONY: sim
# sim: $(addprefix sim-, $(PAR_SETS))
# Set of all sources

MODULESTOP_UART = 

define MODULESTOP_UART_SRC_TEMPLATE

endef
MODULESTOP =

# Define the parameter-specific sources and targets
define MODULESTOP_SRC_TEMPLATE =

# Define all required targets to be included in the modules above.
# The sort function filters double entries.
MODULESTOP_$(1) = $(sort $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(MODULESTOP_SRC) + $(MODULESTOP_UART_SRC)))
# Collect all sources
MODULESTOP += $$(MODULESTOP_$(1))

# Define parameter-specific sources targets
.PHONY: sim-$(1)
sim-$(1): $$(MODULESTOP_$(1))
# Make build directory for the sources


$$(BUILD_DIR_SRC_$(1)):
	mkdir -p $$@


# Sources generation
#

$$(BUILD_DIR_SRC_$(1))/%.v: $$(TOPMODULES_SRC_PATH)/%.v
	cp $$< $$@
$$(BUILD_DIR_SRC_$(1))/%.v: $$(TOPMODULES_SRC_PATH)/testbench/%.v
	cp $$< $$@
$$(BUILD_DIR_SRC_$(1))/%.v: $$(COMMON_SRC_PATH)/%.v
	cp $$< $$@
endef

$(foreach par, $(PAR_SETS), $(eval $(call MODULESTOP_SRC_TEMPLATE,$(par))))


ifeq ($(TOPMODULE_CHECK),${TOPMODULE})

#Add the build directory as order-only-prerequisites to every source file target
$(MODULESTOP): | $$(@D)


# Define Verilator-specific testbench source
# Synthesis, Implement, Generate and Program targets and files
#
# Include vendor- and devices-specific definitions and recipes
include $(MODULESTOP_SRC_PATH)/FPGA/synthesis.mk

# Define the synthesis recipes for Xilinx devices
define MODULESTOP_SYNTH_TEMPLATE =

# Define required report files
MODULESTOP_RESULT_SYNTH_UTILIZATION_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_hierarchical_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_SYNTH_TIMING_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_summary_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_clocks_$(1)_$(2)_$(3).txt


# Perform the synthesis
# #TODO (MAKE versions < 3.8 do not support mutli-target rules)
$$(MODULESTOP_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)): $$(MODULESTOP_$(2)) $$(XILINX_RESOURCE_ANALYSIS_TCL) $$(XILINX_CONSTRAINTS_TIMING_$(1)) | $$(RESULTS_DIR)
	$$(VIVADO) \
	-nojournal \
	-log $$(RESULTS_DIR)/synthesis_$(1)_$(2)_$(3).log \
	-mode batch \
	-source $$(XILINX_RESOURCE_ANALYSIS_TCL) \
	-tclargs \
		"$$(MODULESTOP_$(2))"\
		$$(XILINX_CONSTRAINTS_TIMING_$(1)) \
		$$(XILINX_CONSTRAINTS_PIN_$(1))	\
		$(TOPMODULES_SIMU) \
		$$(XILINX_FPGA_MODEL_ID_$(1)) \
		$$(MODULESTOP_RESULT_SYNTH_UTILIZATION_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_SYNTH_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_SYNTH_TIMING_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_SYNTH_TIMING_SUMMARY_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3)) \
		"parameter_set=$$(id_$(2)) col_width=$(3) e_width=$(3) KEY_START_ADDR=0 BAUD_RATE=$(BAUD_RATE) CLOCK_FPGA=$(CLOCK_FPGA)"


.PHONY: synthesis-$(1)-$(2)-$(3)

synthesis-$(1)-$(2)-$(3): $$(MODULESTOP_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3))
# Define parameter-specific synthesis results
SYNTH_$(2) ?=
SYNTH_$(2) += $$(MODULESTOP_RESULT_SYNTH_CLOCKS_$(1)_$(2)_$(3))
# Make build directory for the testbench sources
$$(BUILD_DIR_TB_$(2)):
	mkdir -p $$@

#
# Sources generation
#
$$(BUILD_DIR_TB_$(2))/%.v: $$(TOPMODULES_SRC_PATH)/testbench/%.v
	cp $$< $$@
endef

$(foreach model, $(XILINX_MODELS), \
	$(foreach par, $(PAR_SETS), \
		$(foreach width, $(SLICED_PUBKEY_COLUMN_WIDTHS), \
			$(eval $(call MODULESTOP_SYNTH_TEMPLATE,$(model),$(par),$(width))) \
		) \
	) \
)
define MODULESTOP_PROGRAM_TEMPLATE  =
# Define required report files
MODULESTOP_RESULT_PROGRAM_UTILIZATION_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_PROGRAM_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_utilization_hierarchical_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_PROGRAM_TIMING_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_PROGRAM_TIMING_SUMMARY_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_timing_summary_$(1)_$(2)_$(3).txt
MODULESTOP_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3) = $$(RESULTS_DIR)/$(TOPMODULE)_clocks_$(1)_$(2)_$(3).txt

# Perform the Program
# #TODO (MAKE versions < 3.8 do not support mutli-target rules)
$$(MODULESTOP_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3)): $$(MODULESTOP_$(2)) $$(XILINX_RESOURCE_PROGRAM_TCL) $$(XILINX_CONSTRAINTS_TIMING_$(1)) | $$(RESULTS_DIR)
	$$(VIVADO) \
	-nojournal \
	-log $$(RESULTS_DIR)/program_$(1)_$(2)_$(3).log \
	-mode batch \
	-source $$(XILINX_RESOURCE_PROGRAM_TCL) \
	-tclargs \
		"$$(MODULESTOP_$(2))" \
		$$(XILINX_CONSTRAINTS_TIMING_$(1)) \
		$$(XILINX_CONSTRAINTS_PIN_$(1))	\
		$(TOPMODULES_SIMU) \
		$$(XILINX_FPGA_MODEL_ID_$(1)) \
		$$(MODULESTOP_RESULT_PROGRAM_UTILIZATION_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_PROGRAM_UTILIZATION_HIERARCHICAL_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_PROGRAM_TIMING_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_PROGRAM_TIMING_SUMMARY_$(1)_$(2)_$(3)) \
		$$(MODULESTOP_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3)) \
		"parameter_set=$$(id_$(2)) col_width=$(3) e_width=$(3) KEY_START_ADDR=0"

.PHONY: program-$(1)

program-$(1): $$(MODULESTOP_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3))

# Define parameter-specific synthesis results
PROGRAM_$(2) ?=
PROGRAM_$(2) += $$(MODULESTOP_RESULT_PROGRAM_CLOCKS_$(1)_$(2)_$(3))
endef

$(foreach par, $(PAR_SETS), $(eval $(call MODULESTOP_PROGRAM_TEMPLATE,$(par))))
# Define synthesis and results targets
define MODULESTOP_RESULTS_TEMPLATE =

.PHONY: synthesis-$(1)
synthesis-$(1): $$(SYNTH_$(1))
endef

$(foreach par, $(PAR_SETS), $(eval $(call MODULESTOP_RESULTS_TEMPLATE,$(par))))
# Define comulated target for the synthesis


.PHONY: synthesis
synthesis: $(addprefix synthesis-, $(PAR_SETS))

.PHONY: program
program: $(addprefix program-, $(PAR_SETS))


$(RESULTS_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
	rm -rf .Xil
	rm -f *.txt *.html *.xml *.bit
endif

# "parameter_set=$$(id_$(2))" \
# "col_width=$(3)" \
# "e_width=$(3)" \
# "KEY_START_ADDR=0" \
# "BAUD_RATE=$(BAUD_RATE)" \
# "CLOCK_FPGA=$(CLOCK_FPGA)"