ifndef RECIVER
RECIVER_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#FULL_ADDER_SUBMODULES :=

RECIVER_SRC = Receiver.v

#FULL_ADDER_SRC += $(foreach module,$(FULL_ADDER_SUBMODULES),$($(module)_SRC))

RECIVER =
error_locator: $(RECIVER)

#error_locator: $(FULL_ADDER)
# Specify targets for each parameter set
define RECIVER_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
RECIVER_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(RECIVER_SRC))

# Collect all targets
RECIVER += RECIVER_$(1)

$$(BUILD_DIR_SRC_$(1))/%.v: $$(RECIVER_SRC_PATH)/%.v
	cp $$< $$@
endef

$(foreach par, $(PAR_SETS), $(eval $(call RECIVER_SRC_TEMPLATE,$(par))))
endif