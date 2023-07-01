ifndef _SOURCE
_SOURCE :=

export DEVICE ?=
export OBJDIR ?=

ifeq ($(DEVICE),)
$(error No DEVICE specified for linker script generator)
endif

export SIMU_DIR := $(CURDIR)/simulation

PLAT_SRC_PATH 	:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PLAT_DIR_SRC	:= $(PLAT_SRC_PATH)/platform
MODULE_DIR_SRC	:= $(PLAT_SRC_PATH)/modules
BUILD_MODULES_DIR_SRC := $(SIMU_DIR)/verilog
VERILOG_FILE	:= $(MODULE_DIR_SRC)/*.v
export VERILOG_FILE
all : simulation
simulation: 
	cp -r $(PLAT_DIR_SRC) $(SIMU_DIR)
	mkdir -p $(BUILD_MODULES_DIR_SRC)
	cp -r $(VERILOG_FILE) $(BUILD_MODULES_DIR_SRC)
	cp -r $(MODULE_DIR_SRC)/verilog.mk $(BUILD_MODULES_DIR_SRC)
	$(MAKE) -C $(SIMU_DIR)
clean:
	rm -rf $(BUILD_DIR)
endif