TRANANDRECEI_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Include the parameter set definitions
include $(TRANANDRECEI_SRC_PATH)/../../FPGA/parameters.mk

# Include toolset
include $(TRANANDRECEI_SRC_PATH)/../../FPGA/tools.mk

TOPMODULE ?= TranAndRecei

# List of the required submodules
TRANANDRECEI_SUBMODULES := BAUD_RATE_GENERATOR FULL_ADDER RECIVER TRANSMITTER

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

#
# Testbench sources definitions
#

# Set the testbench sources
TranAndRecei_TB_SRC = TranAndRecei_tb.v

# Define the comulated target for testbench sources generation
.PHONY: testbench
testbench: $(addprefix testbench-, $(PAR_SETS))

# Set of all testbench sources
TRANANDRECEI_TB =

# Define the parameter-specific testbench targets
define TRANANDRECEI_TB_TEMPLATE =

# Define all required targets to be included in the modules above.
TRANANDRECEI_TB_$(1) = $(addprefix $$(BUILD_DIR_TB_$(1))/,$(TRANANDRECEI_TB_SRC))

# Collect all testbench targets
TRANANDRECEI_TB += $$(TRANANDRECEI_TB_$(1))

# Define parameter-specific testbench targets
.PHONY: testbench-$(1)
testbench-$(1): $$(TRANANDRECEI_$(1)) $$(TRANANDRECEI_TB_$(1))

# Make build directory for the testbench sources
$$(BUILD_DIR_TB_$(1)):
	mkdir -p $$@

#
# Sources generation
#
$$(BUILD_DIR_TB_$(1))/%.v: $$(TRANANDRECEI_SRC_PATH)/testbench/%.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call TRANANDRECEI_TB_TEMPLATE,$(par))))


# Add the build directory as order-only-prerequisites to every source file target
$(TRANANDRECEI) $(TRANANDRECEI_TB): | $$(@D)

# Define Verilator-specific testbench source
TRANANDRECEI_VERILATOR_TB_SRC = $(TRANANDRECEI_SRC_PATH)/testbench/tb.cpp


# Define comulated target for the simulation runs und results generation
.PHONY: sim
sim: $(addprefix sim-, $(PAR_SETS))

# Parameter-specific simulator definitions for multiple public key slice widths
define TRANANDRECEI_SIM_SLICES_TEMPLATE =

# Set of all files to perform the simulation
TRANANDRECEI_SIM_$(1)_$(2) = \
	$$(TRANANDRECEI_VERILATOR_TB_SRC) \
	$$(TRANANDRECEI_TB_$(1)) \
	$$(TRANANDRECEI_$(1))

# Simulation binaries
TRANANDRECEI_VERILATOR_BIN_$(1)_$(2) = $$(BUILD_DIR_TB_$(1))/TRANANDRECEI_tb_$(2).bin

# Simulation performance files
#TRANANDRECEI_RESULT_TB_$(1)_$(2) = $$(RESULTS_DIR)/cycles_profile_$(1)_$(TOPMODULE)_$(2).data

# Define parameter-specific simulation results
SIM_$(1) ?=
SIM_$(1) += $$(TRANANDRECEI_RESULT_TB_$(1)_$(2))

# Simulation binary target
$$(TRANANDRECEI_VERILATOR_BIN_$(1)_$(2)): $$(TRANANDRECEI_SIM_$(1)_$(2)) | $$(RESULTS_DIR)
	$(VERILATOR) \
	--unroll-count 1024 \
	-Wno-fatal \
	--timescale-override 1ps/1ps \
	--trace \
	--Mdir $$(BUILD_DIR_TB_$(1))/obj_dir_$(2) \
	--top-module TranAndRecei_tb \
	-Gparameter_set=$$(id_$(1)) \
	-Gcol_width=$(2) \
	-Ge_width=$(2) \
	-GKEY_START_ADDR=0 \
	-DFILE_CIPHER0_OUT=\"$$(BUILD_DIR_TB_$(1))/cipher_0_$(2).out\" \
	-DFILE_CIPHER1_OUT=\"$$(BUILD_DIR_TB_$(1))/cipher_1_$(2).out\" \
	-DFILE_K_OUT=\"$$(BUILD_DIR_TB_$(1))/K_$(2).out\" \
	-DFILE_ERROR_OUT=\"$$(BUILD_DIR_TB_$(1))/error_$(2).out\" \
	-DFILE_VCD=\"$$(BUILD_DIR_TB_$(1))/wave_$(2).vcd\" \
	-DFILE_CYCLES_PROFILE=\"$$(TRANANDRECEI_RESULT_TB_$(1)_$(2))\" \
	-I$$(BUILD_DIR_SRC_$(1)) \
	-I$$(BUILD_DIR_TB_$(1)) \
	--cc \
	$$(TRANANDRECEI_TB_$(1)) \
	--exe $$< \
	--build \
	-j 8 \
	--threads 1 \
	--x-initial 0 \
	-o $$@
endef
$(foreach par, $(PAR_SETS), \
	$(foreach width, $(SLICED_PUBKEY_COLUMN_WIDTHS), \
		$(eval $(call TRANANDRECEI_SIM_SLICES_TEMPLATE,$(par),$(width)))))

# Define parameter-specific simualtion targets
define TRANANDRECEI_SIM_TARGETS_TEMPLATE =

.PHONY: sim-$(1)
sim-$(1): $$(SIM_$(1))

endef

$(foreach par, $(PAR_SETS), $(eval $(call TRANANDRECEI_SIM_TARGETS_TEMPLATE,$(par))))

#
# Synthesis targets and files
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
		TranAndRecei \
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

# Define synthesis and results targets
define TRANANDRECEI_RESULTS_TEMPLATE =

.PHONY: synthesis-$(1)
synthesis-$(1): $$(SYNTH_$(1))

.PHONY: results-$(1)
results-$(1): $$(SIM_$(1)) $$(SYNTH_$(1))

endef

$(foreach par, $(PAR_SETS), $(eval $(call TRANANDRECEI_RESULTS_TEMPLATE,$(par))))


# Define comulated target for the synthesis
.PHONY: synthesis
synthesis: $(addprefix synthesis-, $(PAR_SETS))

# Define comulated target for all performance results
.PHONY: results
results: $(addprefix results-, $(PAR_SETS))

# Result directory
$(RESULTS_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
endif