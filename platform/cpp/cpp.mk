CXX	:= g++
FLAGS	:= -std=c++11 -Wall -Og -g
OBJDIR  := obj-pc
RTLD	:= ../verilog
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VROOT   := $(VERILATOR_ROOT)
INCS	:= -I$(RTLD)/obj_dir/ -I$(VROOT)/include

VOBJDR	:= $(RTLD)/obj_dir
SYSVDR	:= $(VROOT)/include
#We need to change the name modules or delete the name. In the example, we have 2 moudles
export TOPMODULE_SIMU
MODULES := $(TOPMODULE_SIMU)

SOURCES := $(MODULES).cpp uartsim.cpp uartsim.h #$(MODULES2).cpp 
## }}}
all:	$(OBJDIR)/  $(MODULES) test #$(MODULES2)


# Verilator's generated Makefile sets VM_*
-include $(VOBJDR)/V$(MODULES)_classes.mk
VSRC	:= $(addsuffix .cpp, $(VM_GLOBAL_FAST) $(VM_GLOBAL_SLOW))
VLIB	:= $(addprefix $(OBJDIR)/,$(subst .cpp,.o,$(VSRC)))

$(OBJDIR)/uartsim.o: uartsim.cpp uartsim.h

$(OBJDIR)/%.o: %.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@

$(OBJDIR)/%.o: $(SYSVDR)/%.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@

##Top
TOPSRCS := $(MODULES).cpp uartsim.cpp
TOPOBJ := $(subst .cpp,.o,$(TOPSRCS))
TOPOBJS:= $(addprefix $(OBJDIR)/,$(TOPOBJ)) $(VLIB)
$(MODULES): $(TOPOBJS) $(VOBJDR)/V$(MODULES)__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -lpthread -o $@
## test
## {{{
test:
	./$(MODULES)
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
	rm -f ./$(MODULES)
	rm -f $(MODULES).vcd
	rm -rf $(OBJDIR)/

ifneq ($(MAKECMDGOALS),clean)
-include $(OBJDIR)/depends.txt
endif