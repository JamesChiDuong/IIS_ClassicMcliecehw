.PHONY: all
.DELETE_ON_ERROR:
## }}}
all:	test

YYMMDD		=`date +%Y%m%d`
CXX   		:= g++
FBDIR 		:= .
VDIRFB		:= $(FBDIR)/obj_dir
RTLDR 		:= ../rtl
VERILATOR 	:= verilator
VFLAGS 		:= -Wall --MMD --trace --Wno-fatal -y $(RTLDR) --top-module encap_tb -cc

#We need to change the name modules or delete the name. In the example, we have 2 moudles 
MODULES 	:= encap_tb
MODULES2 	:= fixed_weight

.PHONY: test

test:
	$(VERILATOR)  $(VFLAGS) $(FBDIR)/*.v


$(FBDIR)/$(MODULES2).v:
	$(VERILATOR) $(VFLAGS) -DUSE_UART_LITE --prefix $(MODULES2).v

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