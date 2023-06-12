ifndef FULL_ADDER
FULL_ADDER_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#FULL_ADDER_SUBMODULES :=

FULL_ADDER_SRC = fullAdder.v

#FULL_ADDER_SRC += $(foreach module,$(FULL_ADDER_SUBMODULES),$($(module)_SRC))

FULL_ADDER =
error_locator: $(FULL_ADDER)

#error_locator: $(FULL_ADDER)
# Specify targets for each parameter set
define FULL_ADDER_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
FULL_ADDER_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$$(FULL_ADDER_SRC))

# Collect all targets
FULL_ADDER += FULL_ADDER_$(1)

$$(BUILD_DIR_SRC_$(1))/%.v: $$(FULL_ADDER_SRC_PATH)/%.v
	cp $$< $$@
endef

$(foreach par, $(PAR_SETS), $(eval $(call FULL_ADDER_SRC_TEMPLATE,$(par))))
endif