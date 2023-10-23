SHELL = sh -xv
ifdef SRCDIR

VPATH = $(SRCDIR)
all: $(TARGETS)

export ROOT_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include config.mk

#Set Topmodule

# # Include generated dependencies
#-include $(filter %.d,$(OBJ:.o=.d))

else
#######################################
# Out-of-tree build mechanism.        #
# You shouldn't touch anything below. #
#######################################
.SUFFIXES:

OBJDIR := build

.PHONY: $(OBJDIR)
$(OBJDIR): %:
	+@[ -d $@ ] || mkdir -p $@
	+@$(MAKE) --no-print-directory -r -I$(CURDIR) -C $@ -f $(CURDIR)/Makefile SRCDIR=$(CURDIR) $(MAKECMDGOALS)

.PHONY: clean

clean:
	$(MAKE) -f FPGA.mk clean
	$(MAKE) -f simulation.mk clean
	rm -rf $(OBJDIR)
endif