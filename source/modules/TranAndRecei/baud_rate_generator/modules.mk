ifndef BAUD_RATE_GENERATOR
BAUD_RATE_GENERATOR_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#FULL_ADDER_SUBMODULES :=

BAUD_RATE_GENERATOR_SRC = baud_rate_generator.v

#FULL_ADDER_SRC += $(foreach module,$(FULL_ADDER_SUBMODULES),$($(module)_SRC))

BAUD_RATE_GENERATOR =
error_locator: $(BAUD_RATE_GENERATOR)

#error_locator: $(FULL_ADDER)
# Specify targets for each parameter set
define BAUD_RATE_GENERATOR_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
BAUD_RATE_GENERATOR_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(BAUD_RATE_GENERATOR_SRC))

# Collect all targets
BAUD_RATE_GENERATOR += BAUD_RATE_GENERATOR$(1)

$$(BUILD_DIR_SRC_$(1))/%.v: $$(BAUD_RATE_GENERATOR_SRC_PATH)/%.v
	cp $$< $$@
endef

$(foreach par, $(PAR_SETS), $(eval $(call BAUD_RATE_GENERATOR_SRC_TEMPLATE,$(par))))
endif