VIVADO ?= vivado
PYTHON ?= python3

XILINX_DEVICES_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# TCL scripts
XILINX_RESOURCE_ANALYSIS_TCL = $(XILINX_DEVICES_PATH)/resource_analysis.tcl

# Include supported FPGA models
include $(XILINX_DEVICES_PATH)/models.mk

FPGA_MODELS += $(XILINX_MODELS)

XILINX_TARGETS = 
# Xilinx model specific definitions and targets
define XILINX_TEMPLATE = 

XILINX_CONSTRAINTS_TIMING_$(1) = $(XILINX_DEVICES_PATH)/timing_$(1).xdc

XILINX_TARGETS += $$(XILINX_CONSTRAINTS_TIMING_$(1))


# Model-specific timing constraints
$$(XILINX_CONSTRAINTS_TIMING_$(1)):
	$$(shell $$(PYTHON) -c \
	"import math; print(f\"create_clock -name clk -period {1000.0/$$(XILINX_FPGA_MODEL_FREQ_$(1)).0} [get_ports clk]\")" > $$@)
endef
$(foreach model, $(XILINX_MODELS), \
		$(eval $(call XILINX_TEMPLATE,$(model))) \
)

clean_xilinx:
	rm -rf $(XILINX_TARGETS)
