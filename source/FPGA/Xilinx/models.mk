# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 
XILINX_MODELS = \
	artix7_100t

define XILINX_MODELS_TEMPLATE =

ifeq ($(1), artix7_100t)
	XILINX_FPGA_MODEL_$(1) = $(1)
	XILINX_FPGA_MODEL_ID_$(1) = xc7a100tcsg324-1
	XILINX_FPGA_MODEL_FREQ_$(1) = 400
endif

endef
# Define all parameters globally
$(foreach model, $(XILINX_MODELS), $(eval $(call XILINX_MODELS_TEMPLATE,$(model))))