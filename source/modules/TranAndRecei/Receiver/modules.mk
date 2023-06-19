# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 
ifndef RECEIVER
RECEIVER_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#FULL_ADDER_SUBMODULES :=

RECEIVER_SRC = Receiver.v

#FULL_ADDER_SRC += $(foreach module,$(FULL_ADDER_SUBMODULES),$($(module)_SRC))

RECEIVER =
error_locator: $(RECEIVER)

#error_locator: $(FULL_ADDER)
# Specify targets for each parameter set
define RECEIVER_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
RECEIVER_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(RECEIVER_SRC))

# Collect all targets
RECEIVER += RECEIVER_$(1)

$$(BUILD_DIR_SRC_$(1))/%.v: $$(RECEIVER_SRC_PATH)/%.v
	cp $$< $$@
endef

$(foreach par, $(PAR_SETS), $(eval $(call RECEIVER_SRC_TEMPLATE,$(par))))
endif