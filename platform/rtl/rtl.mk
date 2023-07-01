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
.PHONY: all
all : test

.DELETE_ON_ERROR:
YYMMDD =`date + %Y%m%d`
CXX 	:= g++;
FBDIR 	:= .
VDIRFB 	:= $(FBDIR)/obj_dir
VERILATOR := verilator 

.PHONY: test
test: $(VDIRFB)/Vbaud_rate_generator__ALL.a
test: $(VDIRFB)/VTransmitter__ALL.a
test: $(VDIRFB)/VReceiver__ALL.a

$(VDIRFB)/Vbaud_rate_generator__ALL.a: $(VDIRFB)/Vbaud_rate_generator.cpp
$(VDIRFB)/VTransmitter__ALL.a: $(VDIRFB)/VTransmitter.cpp
$(VDIRFB)/VReceiver__ALL.a: $(VDIRFB)/VReceiver.cpp

$(VDIRFB)/V%.mk:  $(VDIRFB)/%.h
$(VDIRFB)/V%.h:   $(VDIRFB)/%.cpp
$(VDIRFB)/V%.cpp: $(FBDIR)/%.v
	$(VERILATOR) --trace -MMD -Wall -cc $*.v

tags: $(wildcard *.v)
	ctags *.v


.PHONY: clean_rtl
clean_rtl:
	rm -rf tags $(VDIRFB)/

DEPS := $(wildcard $(VDIRFB)/*.d)

ifneq ($(MAKECMDGOALS),clean_rtl)
ifneq ($(DEPS),)
include $(DEPS)
endif
endif