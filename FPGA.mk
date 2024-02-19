ifndef _SOURCE
_SOURCE :=

export ROOT_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

BUILD_PATH := $(ROOT_PATH)/build

KAT_DIR = $(ROOT_PATH)/host/kat/kat_generate
# Include the parameter set definitions
PAR_FILE := $(ROOT_PATH)/modules/FPGA/parameters.mk
include $(PAR_FILE)
include targets.mk
# Include toolset
TOOLS_FILE := $(ROOT_PATH)/modules/FPGA/tools.mk
NO_CHECK := TRUE
include $(TOOLS_FILE)
undefine NO_CHECK
NO_SUB_INCLUDES = True

XILINX_MODELS_FILE := $(ROOT_PATH)/modules/FPGA/Xilinx/models.mk
include $(XILINX_MODELS_FILE)

# Source code directory for the parametrizable modules
MODULES_DIR 	:= $(ROOT_PATH)/modules/$(TOPMODULES)


export TOPMODULES
# TOPMODULES = Data_Receiver
# Define individual targets for the single steps.
SOURCES := $(addsuffix -sources,$(TOPMODULES))
SYNTHESIS := $(addsuffix -synthesis,$(TOPMODULES))
PROGRAM := $(addsuffix -program,$(TOPMODULES))
RESULTS := $(addsuffix -results,$(TOPMODULES))
# Comulate the targets.
TARGETS :=$(SYNTHESIS) $(PROGRAM) $(RESULTS)

# Build directory
BUILD_DIR = $(ROOT_PATH)/build
NPROC ?= 1

export SIMU_DIR := $(BUILD_DIR)/FPGA

# PLAT_SRC_PATH 	:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PLAT_DIR_SRC	:= $(ROOT_PATH)/platform
MODULE_DIR_SRC	:= $(ROOT_PATH)/modules
export BUILD_MODULES_DIR_SRC := $(SIMU_DIR)/verilog
# VERILOG_FILE	:= $(MODULE_DIR_SRC)/*.v


.PHONY: all
all: results

.SECONDEXPANSION:

.PHONY: program
program: $(PROGRAM)

.PHONY: synthesis
synthesis: $(SYNTHESIS)

.PHONY: results
results: $(RESULTS)

.PHONY: $(TARGETS)
$(TARGETS):
	$(MAKE) -C $(ROOT_PATH)/host/kat gen-kat -j$(NPROC) KAT_DIR=$(KAT_DIR) PAR_SETS=$(PAR_MODULE)
	$(MAKE) -C $(MODULES_DIR)\
		-f module.mk $(lastword $(subst -, ,$@)) \
		-j$(NPROC) \
		BUILD_DIR=$(SIMU_DIR) \
		PAR_SETS="$(PAR_SETS)" \
		XILINX_MODELS="$(XILINX_MODELS)" \
		SYSTEMIZER="$(SYSTEMIZER)"

clean:
	rm -rf $(BUILD_PATH)
	rm -rf $(ROOT_PATH)/modules/$(TOPMODULES)/*.bit
	rm -rf $(ROOT_PATH)/modules/$(TOPMODULES)/*.html
	rm -rf $(ROOT_PATH)/modules/$(TOPMODULES)/*.xml
	rm -rf $(ROOT_PATH)/modules/$(TOPMODULES)/*.txt
	rm -rf $(ROOT_PATH)/modules/$(TOPMODULES)/.Xil
	rm -rf $(ROOT_PATH)/modules/$(TOPMODULES)/*.log
.PHONY: help

help:
	@printf "Target list:\n\n"
	@printf "  $(TOPMODULES):\n\t Build sources, testbenches, and run simulations and\n"
	@printf "\t syntheses for the topmodules. (Same as \"<topmodule>-results\")\n\n"
	@printf "  sources:\n\t Build the sources for all topmodules.\n\n"
	@printf "  $(SOURCES):\n\t Build the sources for a topmodule.\n\n"
	@printf "  testbench:\n\t Build the testbench sources for all topmodules.\n\n"
	@printf "  $(TESTBENCH):\n\t Build the testbench sources for a topmodule.\n\n"
	@printf "  sim:\n\t Run the simulations for all topmodules.\n\n"
	@printf "  $(SIM):\n\t Run the simulations for a topmodule.\n\n"
	@printf "  synthesis:\n\t Run the syntheses for all topmodules.\n\n"
	@printf "  $(SYNTHESIS):\n\t Run the syntheses for a topmodule.\n\n"
	@printf "  results:\n\t Generate sources and run the simulation and the syntheses for all topmodules.\n\n"
	@printf "  $(RESULTS):\n\t Generate sources and run the simulation and the syntheses for a topmodule.\n\n"
	@printf "  kat:\n\t Generate Known Answer Tests (KATs) for Classic McEliece.\n\n"
	@printf "  clean:\n\t Remove the entire build directory.\n\n"
	@printf "\nMakefile Variables:\n\n"
	@printf "  BUILD_DIR=<path>:\n\t Set the build directory for all targets.\n"
	@printf "  \t Default: \"$(BUILD_DIR)\"\n\n"
	@printf "  PAR_SETS=<list>:\n\t List of target Classic McEliece parameter sets.\n"
	@printf "  \t Predefined from specification:\t \"$(PAR_SETS)\"\n"
	@printf "  \t Predefined toy sets:\t\t \"$(PAR_SETS_TOY)\"\n\n"
	@printf "  \t Find definitions in \"$(PAR_FILE)\".\n\n"
	@printf "  XILINX_MODELS=<list>:\n\t List of target Xilinx FPGA models for the analyses.\n"
	@printf "  \t Default:\t \"$(XILINX_MODELS)\"\n\n"
	@printf "  \t Find definitions in \"$(XILINX_MODELS_FILE)\".\n\n"
	@printf "  SYSTEMIZER=<name>:\n\t Name of the desired systemizer.\n"
	@printf "  \t Default:\t \"$(SYSTEMIZER)\"\n\n"
	@printf "  \t Available systemizers: $(SYSTEMIZERS).\n\n"
	@printf "  NPROC=<num>:\n\t Set number of parallel make jobs.\n"
	@printf "\nVariables of Required Tools:\n\n"
	@printf "  MAKE=<[path to] make>:\n\t Set GNU Make binary.\t\t (Default: $(MAKE), required: >= $(MAKE_VERSION_MIN), current: $(MAKE_VERSION)).\n\n"
	@printf "  PYTHON=<[path to] python>:\n\t Set Python binary.\t\t (Default: $(PYTHON), required: >= $(PYTHON_VERSION_MIN), current: $(PYTHON_VERSION)).\n\n"
	@printf "  SAGE=<[path to] sage>:\n\t Set SageMath binary.\t\t (Default: $(SAGE), required: >= $(SAGE_VERSION_MIN), current: $(SAGE_VERSION)).\n\n"
	@printf "  VERILATOR=<[path to] verilator>:\n\t Set Verilator binary.\t\t (Default: $(VERILATOR), required: >= $(VERILATOR_VERSION_MIN), current: $(VERILATOR_VERSION)).\n\n"
	@printf "  VIVADO=<[path to] vivado>:\n\t Set Xilinx Vivado binary.\t (Default: $(VIVADO), required: >= $(VIVADO_VERSION_MIN), current: $(VIVADO_VERSION)).\n\n"

endif