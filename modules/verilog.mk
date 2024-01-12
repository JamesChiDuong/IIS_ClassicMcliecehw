.PHONY: all
.DELETE_ON_ERROR:
## }}}
all:	test

export TOPMODULES_SIMU
export ROOT_PATH
export BAUD_RATE
export CLOCK_FPGA
PAR_FILE := $(ROOT_PATH)/modules/FPGA/parameters.mk
include $(PAR_FILE)

YYMMDD		=`date +%Y%m%d`
CXX   		:= g++
FBDIR 		:= .
VDIRFB		:= $(FBDIR)/obj_dir
RTLDR 		:= ../rtl
VERILATOR 	:= verilator
MODULES 	:= $(TOPMODULES_SIMU)
KAT_FILE_SEED := mem_512.kat
KAT_FILE_PUBKEY := pubkey_32.kat
FILE_VCD	:= -DFILE_VCD=\"$(MODULES).vcd\"
FILE_CYCLES_PROFILE := -DFILE_CYCLES_PROFILE=\"cycles_profile.data\"
FILE_K_OUT	:= -DFILE_K_OUT=\"K_$(MODULES).out\"
FILE_CIPHER0_OUT := -DFILE_CIPHER0_OUT=\"cipher_0.out\"
FILE_CIPHER1_OUT := -DFILE_CIPHER1_OUT=\"cipher_1.out\"
FILE_ERROR_OUT	 := -DFILE_ERROR_OUT=\"error.out\"
FILE_MEM_SEED    := -DFILE_MEM_SEED=\"$(ROOT_PATH)/host/kat/kat_generate/$(KAT_FILE_SEED)\"
FILE_PK_SLICED	 :=	-DFILE_PK_SLICED=\"$(ROOT_PATH)/host/kat/kat_generate/$(KAT_FILE_PUBKEY)\"
BAUDRATE		 := -GBAUD_RATE=$(BAUD_RATE)
CLOCKFPGA        := -GCLOCK_FPGA=$(CLOCK_FPGA)
VFLAGS 		:= -Wall --MMD --trace --unroll-count 1024 --Wno-fatal --timescale-override 1ps/1ps -y $(RTLDR) --top-module $(MODULES) \-GKEY_START_ADDR=0 \-Gparameter_set=1 \-Gcol_width=32 \--Ge_width=32 \$(BAUDRATE) \$(CLOCKFPGA) \$(FILE_VCD) \$(FILE_CYCLES_PROFILE) \$(FILE_K_OUT) \$(FILE_CIPHER0_OUT) \$(FILE_CIPHER1_OUT) \$(FILE_ERROR_OUT) \$(FILE_MEM_SEED) \$(FILE_PK_SLICED) --cc \clog2.v

#We need to change the name modules or delete the name. In the example, we have 2 moudles

#-Wno-BLKANDNBLK 

.PHONY: test

test: $(VDIRFB)/V$(MODULES)__ALL.a

$(VDIRFB)/V$(MODULES)__ALL.a: 	$(VDIRFB)/V$(MODULES).cpp
$(VDIRFB)/V%.mk:  $(VDIRFB)/V%.h
$(VDIRFB)/V%.h:   $(VDIRFB)/V%.cpp
$(VDIRFB)/V%.cpp: $(FBDIR)/%.v
	$(VERILATOR)  $(VFLAGS) $(FBDIR)/*.v


$(FBDIR)/$(MODULES).v:
	$(VERILATOR) $(VFLAGS) -DUSE_UART_LITE --prefix $(MODULES).v

$(VDIRFB)/V%__ALL.a: $(VDIRFB)/V%.cpp
	cd $(VDIRFB); make -f V$*.mk
## }}}

## TAGS
## {{{
tags: $(wildcard *.v) $(wildcard $(RTLDR)/*.v)
	ctags *.v $(RTLDR)/*.v
## }}}

## Clean
## {{{
.PHONY: clean
clean:
	rm -rf tags $(VDIRFB)/
## }}}

## Automatic dependency handling
## {{{
DEPS := $(wildcard $(VDIRFB)/*.d)

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(DEPS),)
include $(DEPS)
endif
endif