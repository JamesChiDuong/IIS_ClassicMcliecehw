# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 

MAKE ?= make
MAKE_VERSION_MIN := 4.3
MAKE_VERSION := $(shell $(MAKE) --version | grep Make | cut -d" " -f3)
ifndef NO_CHECK
ifeq ($(shell printf '%s\n%s\n' $(MAKE_VERSION_MIN) $(MAKE_VERSION) | sort --check=quiet --version-sort; echo $$?), 1)
    $(error Make version >= $(MAKE_VERSION_MIN) required, $(MAKE_VERSION) installed.)
endif
endif

PYTHON ?= python3
PYTHON_VERSION_MIN := 3.8.0
PYTHON_VERSION := $(shell $(PYTHON) --version | cut -d" " -f2)
ifndef NO_CHECK
ifeq ($(shell printf '%s\n%s\n' $(PYTHON_VERSION_MIN) $(PYTHON_VERSION) | sort --check=quiet --version-sort; echo $$?), 1)
    $(error Python version >= $(PYTHON_VERSION_MIN) required, $(PYTHON_VERSION) installed.)
endif
endif

SAGE ?= sage
SAGE_VERSION_MIN := 9.3
SAGE_VERSION := $(shell $(SAGE) --version | grep SageMath | cut -d"," -f1 | cut -d" " -f3)
ifndef NO_CHECK
ifeq ($(shell printf '%s\n%s\n' $(SAGE_VERSION_MIN) $(SAGE_VERSION) | sort --check=quiet --version-sort; echo $$?), 1)
   $(error SageMath version >= $(SAGE_VERSION_MIN) required, $(SAGE_VERSION) installed.)
endif
endif

VERILATOR ?= verilator
VERILATOR_VERSION_MIN := 4.038
VERILATOR_VERSION := $(shell $(VERILATOR) --version | cut -d" " -f2)
ifndef NO_CHECK
ifeq ($(shell printf '%s\n%s\n' $(VERILATOR_VERSION_MIN) $(VERILATOR_VERSION) | sort --check=quiet --version-sort; echo $$?), 1)
   $(error Verilator version >= $(VERILATOR_VERSION_MIN) required, $(VERILATOR_VERSION) installed.)
endif
endif

VIVADO ?= vivado
VIVADO_VERSION_MIN := 2019.2.1
VIVADO_VERSION := $(shell $(VIVADO) -version | grep Vivado | cut -d" " -f2 | cut -d"v" -f2)
ifndef NO_CHECK
ifeq ($(shell printf '%s\n%s\n' $(VIVADO_VERSION_MIN) $(VIVADO_VERSION) | sort --check=quiet --version-sort; echo $$?), 1)
    $(error Vivado version >= $(VIVADO_VERSION_MIN) required, $(VIVADO_VERSION) installed.)
endif
endif