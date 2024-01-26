ifndef _TARGETS
_TARGETS :=

TARGET ?=

export TOPMODULES := encap
export TOPMODULES_SIMU := encap_tb

export CLOCK_FPGA := 100000000

ifeq ($(TARGET),unix)
DEVICE := x86_64
endif

ifeq ($(TARGET),sim)
PLATFORM := simulation
DEVICE := YOUR PC
export BAUD_RATE := 3000000
#OPENCM3_TARGETS := lm3s
endif

ifeq ($(TARGET),ArtixA7)
PLATFORM := FPGA
DEVICE := artix7_100t
export BAUD_RATE := 9600
#OPENCM3_TARGETS := stm32/f4
endif

RETAINED_VARS += TARGET PLATFORM


ifneq ($(TARGET),)
$(info ---Picking PLATFORM = $(PLATFORM) DEVICE=$(DEVICE) for target $(TARGET)---)
endif

endif