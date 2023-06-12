ifndef _SOURCE
_SOURCE :=

export DEVICE ?=

ifeq ($(DEVICE),)
$(error No DEVICE specified for linker script generator)
endif

export SIMU_DIR := $(CURDIR)/simulation

all: simulation_tar

simulation_tar: source/simulation.tar.gz
	$(Q)tar xf $<
	@echo "  BUILD   simulation"
	$(Q)$(MAKE) -C $(SIMU_DIR) TARGETS=$(OPENCM3_TARGETS)
	$(Q)touch $@
clean:
	rm -rf $(BUILD_DIR)
endif