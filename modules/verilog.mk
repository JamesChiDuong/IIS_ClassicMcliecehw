.PHONY: all
.DELETE_ON_ERROR:
## }}}
all:	test

YYMMDD=`date +%Y%m%d`
CXX   := g++
FBDIR := .
VDIRFB:= $(FBDIR)/obj_dir
RTLDR := ../rtl
VERILATOR := verilator
VFLAGS := -Wall --MMD --trace -y $(RTLDR) -cc
.PHONY: test testDataTransmitter testDataReceiver testTranAndRecei
## }}}
#test: testline testlinelite testhello testhellolite speechfifo speechfifolite
test:testDataTransmitter testDataTransmitterlite testTranAndRecei testTranAndReceilite testDataReceiver testDataReceiverlite

testDataTransmitter: 	$(VDIRFB)/VData_Transmitter__ALL.a
testDataTransmitterlite:$(VDIRFB)/VData_Transmitterlite__ALL.a

testDataReceiver: 		$(VDIRFB)/VData_Receiver__ALL.a
testDataReceiverlite: 	$(VDIRFB)/VData_Receiverlite__ALL.a

testTranAndRecei: 			$(VDIRFB)/VTranAndRecei__ALL.a
testTranAndReceilite: 		$(VDIRFB)/VTranAndReceilite__ALL.a

$(VDIRFB)/VData_Transmitter__ALL.a: 	$(VDIRFB)/VData_Transmitter.cpp
$(VDIRFB)/VData_Transmitterlite__ALL.a: $(VDIRFB)/VData_Transmitterlite.cpp
$(VDIRFB)/VData_Receiver__ALL.a: 		$(VDIRFB)/VData_Receiver.cpp
$(VDIRFB)/VData_Receiverlite__ALL.a: 	$(VDIRFB)/VData_Receiverlite.cpp
$(VDIRFB)/VTranAndRecei__ALL.a: 		$(VDIRFB)/VTranAndRecei.cpp
$(VDIRFB)/VTranAndReceilite__ALL.a: 	$(VDIRFB)/VTranAndReceilite.cpp

$(VDIRFB)/V%.mk:  $(VDIRFB)/V%.h
$(VDIRFB)/V%.h:   $(VDIRFB)/V%.cpp
$(VDIRFB)/V%.cpp: $(FBDIR)/%.v
	$(VERILATOR) $(VFLAGS) $*.v


$(VDIRFB)/VData_Transmitterlite.cpp: 		$(FBDIR)/Data_Transmitter.v
	$(VERILATOR) $(VFLAGS) -DUSE_UART_LITE --prefix VData_Transmitterlite Data_Transmitter.v

$(VDIRFB)/VData_Receiverlite.cpp: 			$(FBDIR)/Data_Receiver.v
	$(VERILATOR) $(VFLAGS) -DUSE_UART_LITE --prefix VData_Receiverlite Data_Receiver.v

$(VDIRFB)/VTranAndReceilite.cpp: 			$(FBDIR)/TranAndRecei.v
	$(VERILATOR) $(VFLAGS) -DUSE_UART_LITE --prefix VTranAndReceilite TranAndRecei.v

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