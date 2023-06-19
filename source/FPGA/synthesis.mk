# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 


# Avoid multiple includes
ifndef SYNTHESIS

SYNTHESIS = TRUE

# Common synthesis defines and targets.
SYNTHESIS_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Collect all FPGA models
FPGA_MODELS =

# Include device-specific makefiles
include $(SYNTHESIS_PATH)/Xilinx/xilinx.mk

clean_synthesis: clean_xilinx

endif
