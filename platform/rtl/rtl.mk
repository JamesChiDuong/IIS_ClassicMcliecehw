ifndef BAUD_RATE_GENERATOR
BAUD_RATE_GENERATOR_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

BAUD_RATE_GENERATOR_SRC = baud_rate_generator.v


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
ifndef RECEIVER
RECEIVER_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))


RECEIVER_SRC = Receiver.v



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

ifndef TRANSMITTER
TRANSMITTER_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))


TRANSMITTER_SRC = Transmitter.v



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
