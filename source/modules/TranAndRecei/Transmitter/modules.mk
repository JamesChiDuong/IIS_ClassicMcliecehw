ifndef TRANSMITTER
TRANSMITTER_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#FULL_ADDER_SUBMODULES :=

TRANSMITTER_SRC = Transmitter.v

#FULL_ADDER_SRC += $(foreach module,$(FULL_ADDER_SUBMODULES),$($(module)_SRC))

TRANSMITTER =
error_locator: $(TRANSMITTER)

#error_locator: $(FULL_ADDER)
# Specify targets for each parameter set
define TRANSMITTER_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
TRANSMITTER_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(TRANSMITTER_SRC))

# Collect all targets
TRANSMITTER += TRANSMITTER_$(1)

$$(BUILD_DIR_SRC_$(1))/%.v: $$(TRANSMITTER_SRC_PATH)/%.v
	cp $$< $$@
endef

$(foreach par, $(PAR_SETS), $(eval $(call TRANSMITTER_SRC_TEMPLATE,$(par))))
endif