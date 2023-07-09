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
VFLAGS 		:= -Wall --MMD --trace -y $(RTLDR) -cc

#We need to change the name modules or delete the name. In the example, we have 2 moudles 
MODULES 	:= TranAndRecei
MODULES2 	:= Data_Receiver

.PHONY: test  test$(MODULES) test$(MODULES2)
## }}}
#test: testline testlinelite testhello testhellolite speechfifo speechfifolite
test:$(MODULES)  $(MODULES2) 

$(MODULES2): 		$(VDIRFB)/V$(MODULES2)__ALL.a


$(MODULES): 		$(VDIRFB)/V$(MODULES)__ALL.a


$(VDIRFB)/V$(MODULES2)__ALL.a: 		$(VDIRFB)/V$(MODULES2).cpp

$(VDIRFB)/V$(MODULES)__ALL.a: 		$(VDIRFB)/V$(MODULES).cpp


$(VDIRFB)/V%.mk:  $(VDIRFB)/V%.h
$(VDIRFB)/V%.h:   $(VDIRFB)/V%.cpp
$(VDIRFB)/V%.cpp: $(FBDIR)/%.v
	$(VERILATOR) $(VFLAGS) $*.v


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