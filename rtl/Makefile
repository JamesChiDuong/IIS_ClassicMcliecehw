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
test: $(VDIRFB)/VfullAdder__ALL.a

$(VDIRFB)/Vbaud_rate_generator__ALL.a: $(VDIRFB)/Vbaud_rate_generator.cpp
$(VDIRFB)/VTransmitter__ALL.a: $(VDIRFB)/VTransmitter.cpp
$(VDIRFB)/VReceiver__ALL.a: $(VDIRFB)/VReceiver.cpp
$(VDIRFB)/VfullAdder__ALL.a: $(VDIRFB)/VfullAdder.cpp

$(VDIRFB)/V%.mk:  $(VDIRFB)/%.h
$(VDIRFB)/V%.h:   $(VDIRFB)/%.cpp
$(VDIRFB)/V%.cpp: $(FBDIR)/%.v
	$(VERILATOR) --trace -MMD -Wall -cc $*.v

tags: $(wildcard *.v)
	ctags *.v

.PHONY: clean
clean:
	rm -rf tags $(VDIRFB)/

DEPS := $(wildcard $(VDIRFB)/*.d)

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(DEPS),)
include $(DEPS)
endif
endif