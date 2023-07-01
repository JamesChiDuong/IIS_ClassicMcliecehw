
CXX	:= g++
FLAGS	:= -std=c++11 -Wall -Og -g
OBJDIR  := obj-pc
RTLD	:= ../verilog
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VROOT   := $(VERILATOR_ROOT)
INCS	:= -I$(RTLD)/obj_dir/ -I$(VROOT)/include
SOURCES := Data_Transmitter.cpp Data_Receiver.cpp TranAndRecei.cpp uartsim.cpp uartsim.h
VOBJDR	:= $(RTLD)/obj_dir
SYSVDR	:= $(VROOT)/include
## }}}
all:	$(OBJDIR)/ Data_Transmitter Data_Transmitterlite Data_Receiver Data_Receiverlite TranAndRecei TranAndReceilite test

# Verilator's generated Makefile sets VM_*
-include $(VOBJDR)/VData_Transmitter_classes.mk
VSRC	:= $(addsuffix .cpp, $(VM_GLOBAL_FAST) $(VM_GLOBAL_SLOW))
VLIB	:= $(addprefix $(OBJDIR)/,$(subst .cpp,.o,$(VSRC)))

$(OBJDIR)/uartsim.o: uartsim.cpp uartsim.h

$(OBJDIR)/%.o: %.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@

$(OBJDIR)/%.o: $(SYSVDR)/%.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@


## Data_Transmitter
## {{{
# Sources necessary to build the helloworld test (txuart test)
LINSRCS := Data_Transmitter.cpp uartsim.cpp
LINOBJ := $(subst .cpp,.o,$(LINSRCS))
LINOBJS:= $(addprefix $(OBJDIR)/,$(LINOBJ)) $(VLIB)
Data_Transmitter: $(LINOBJS) $(VOBJDR)/VData_Transmitter__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@
## }}}

## Data_Transmitterlite
## {{{
$(OBJDIR)/Data_Transmitterlite.o: Data_Transmitter.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -DUSE_UART_LITE -c $< -lpthread -o $@


LINLTOBJ := Data_Transmitterlite.o uartsim.o
LINLTOBJS:= $(addprefix $(OBJDIR)/,$(LINLTOBJ)) $(VLIB)
Data_Transmitterlite: $(LINLTOBJS) $(VOBJDR)/VData_Transmitterlite__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@
## }}}

##Data_Receiver
DATARESRCS := Data_Receiver.cpp uartsim.cpp
DATAREOBJ := $(subst .cpp,.o,$(DATARESRCS))
DATAREOBJS:= $(addprefix $(OBJDIR)/,$(DATAREOBJ)) $(VLIB)
Data_Receiver: $(DATAREOBJS) $(VOBJDR)/VData_Receiver__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@

##Data_Receiverlite
$(OBJDIR)/Data_Receiverlite.o: Data_Receiver.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -DUSE_UART_LITE -c $< -lpthread -o $@
DATARELTOBJ := Data_Receiverlite.o uartsim.o
DATARELTOBJS:= $(addprefix $(OBJDIR)/,$(DATARELTOBJ)) $(VLIB)
Data_Receiverlite: $(DATARELTOBJS) $(VOBJDR)/VData_Receiverlite__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@

##Top
TOPSRCS := TranAndRecei.cpp uartsim.cpp
TOPOBJ := $(subst .cpp,.o,$(TOPSRCS))
TOPOBJS:= $(addprefix $(OBJDIR)/,$(TOPOBJ)) $(VLIB)
TranAndRecei: $(TOPOBJS) $(VOBJDR)/VTranAndRecei__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@

##Toplite
$(OBJDIR)/TranAndReceilite.o: TranAndRecei.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -DUSE_UART_LITE -c $< -lpthread -o $@
TOPLTOBJ := TranAndReceilite.o uartsim.o
TOPLTOBJS:= $(addprefix $(OBJDIR)/,$(TOPLTOBJ)) $(VLIB)
TranAndReceilite: $(TOPLTOBJS) $(VOBJDR)/VTranAndReceilite__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@
## test
## {{{
test:
#	./Data_Transmitter
#	./Data_Transmitterlite
#	./Data_Receiver
#	./Data_Receiverlite
	./TranAndRecei
#	./Toplite
#
define	build-depends
	$(mk-objdir)
	@echo "Building dependency file"
	@$(CXX) $(FLAGS) $(INCS) -MM $(SOURCES) > $(OBJDIR)/xdepends.txt
	@sed -e 's/^.*.o: /$(OBJDIR)\/&/' < $(OBJDIR)/xdepends.txt > $(OBJDIR)/depends.txt
	@rm $(OBJDIR)/xdepends.txt
endef

.PHONY: depends
depends:
	$(build-depends)

$(OBJDIR)/depends.txt: depends

#
define	mk-objdir
	@bash -c "if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi"
endef

#
# The "tags" target
#
tags:	$(SOURCES) $(HEADERS)
	@echo "Generating tags"
	@ctags $(SOURCES) $(HEADERS)

.PHONY: clean
clean:
	rm -f ./Data_Receiver ./Data_Receiverlite
	rm -f ./Data_Transmitter ./Data_Transmitterlite
	rm -f ./TranAndRecei ./TranAndReceilite
	rm -f Data_Receiver.vcd Data_Transmitter.vcd TranAndRecei.vcd

	rm -rf $(OBJDIR)/

ifneq ($(MAKECMDGOALS),clean)
-include $(OBJDIR)/depends.txt
endif