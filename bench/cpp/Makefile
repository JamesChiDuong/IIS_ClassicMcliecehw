################################################################################
##
## Filename: 	Makefile
## {{{
## Project:	wbuart32, a full featured UART with simulator
##
## Purpose:	To test a group of Verilator modules: txuart (UART transmitter),
##		rxuart (UART receiver/sink) and wbuart (UART module, containing
##	both receiver and transmitter, with FIFOs, controlled via wishbone).
##
##
## Targets:
##	test
##		Perform both tests.  The end result should be either a PASS
##		or a FAIL.
##
##	helloworld
##		A non-automated, and less interactive test than the others.  In
##		this test, the UART simply produces a Hello World message to the
##		screen over and over again.
##
##	linetest
##		An automated test of both txuart and rxuart.  The test works
##		by sending a message through the rxuart, and receiving the
##		message via the txuart.  This depends upon a Verilog test
##		infrastructure, linetest.v.
##
##		This test may be ran in an interactive mode.  In this mode,
##		characters written to the UART will be reflected back upon
##		the entrance of a return character.
##
##	speechtest
##		An automated test of the wbuart, txuart, and fifo.  In this
##		case, the test RTL produces a copy of the Gettysburg address,
##		filling the FIFO at 12/16 at a time.  In automated mode, the
##		speechtest will compare the output against against a text copy
##		of the speech, and report upon any success or failure.
##
##		In interactive mode, the test will repeatedly print out the
##		Gettysburg address until stopped.  (It may take a significant
##		amount of time between copies of the Gettysburg address ...)
##
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
## }}}
## Copyright (C) 2015-2022, Gisselquist Technology, LLC
## {{{
## This program is free software (firmware): you can redistribute it and/or
## modify it under the terms of  the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program.  (It's in the $(ROOT)/doc directory, run make with no
## target there if the PDF file isn't present.)  If not, see
## <http://www.gnu.org/licenses/> for a copy.
##
## License:	GPL, v3, as defined and found on www.gnu.org,
##		http://www.gnu.org/licenses/gpl.html
##
##
################################################################################
##
##
CXX	:= g++
FLAGS	:= -std=c++11 -Wall -Og -g
OBJDIR  := obj-pc
RTLD	:= ../verilog
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VROOT   := $(VERILATOR_ROOT)
INCS	:= -I$(RTLD)/obj_dir/ -I$(VROOT)/include
SOURCES := Data_Transmitter.cpp Data_Receiver.cpp Top.cpp uartsim.cpp uartsim.h
VOBJDR	:= $(RTLD)/obj_dir
SYSVDR	:= $(VROOT)/include
## }}}
all:	$(OBJDIR)/ Data_Transmitter Data_Transmitterlite Data_Receiver Data_Receiverlite Top Toplite test

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
TOPSRCS := Top.cpp uartsim.cpp
TOPOBJ := $(subst .cpp,.o,$(TOPSRCS))
TOPOBJS:= $(addprefix $(OBJDIR)/,$(TOPOBJ)) $(VLIB)
Top: $(TOPOBJS) $(VOBJDR)/VTop__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@

##Toplite
$(OBJDIR)/Toplite.o: Top.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -DUSE_UART_LITE -c $< -lpthread -o $@
TOPLTOBJ := Toplite.o uartsim.o
TOPLTOBJS:= $(addprefix $(OBJDIR)/,$(TOPLTOBJ)) $(VLIB)
Toplite: $(TOPLTOBJS) $(VOBJDR)/VToplite__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@
## test
## {{{
test: 
#	./Data_Transmitter
#	./Data_Transmitterlite
#	./Data_Receiver
#	./Data_Receiverlite
	./Top
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
	rm -f ./Top ./Toplite
	rm -f Data_Receiver.vcd Data_Transmitter.vcd Top.vcd

	rm -rf $(OBJDIR)/

ifneq ($(MAKECMDGOALS),clean)
-include $(OBJDIR)/depends.txt
endif