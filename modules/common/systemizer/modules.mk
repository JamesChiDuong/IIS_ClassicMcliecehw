# This (sub-)makefile is part of the Classic McEliece hardware source code.
# 
# Copyright (C) 2022
#
# Authors: Norman Lahr <norman@lahr.email>
# 
# This source code is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
# 
# This source code is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# this source code. If not, see <https://www.gnu.org/licenses/>. 

SYSTEMIZER_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifndef NO_SUB_INCLUDES
ifeq ($(SYSTEMIZER),SYSTEMIZER_SPGF2)
include $(SYSTEMIZER_SRC_PATH)/single_pass_GF2/module.mk
endif

ifeq ($(SYSTEMIZER),SYSTEMIZER_SPGF2_REDO)
include $(SYSTEMIZER_SRC_PATH)/single_pass_GF2_redo/module.mk
endif

ifeq ($(SYSTEMIZER),SYSTEMIZER_SPGFX)
include $(SYSTEMIZER_SRC_PATH)/single_pass_GFx/module.mk
endif

ifeq ($(SYSTEMIZER),SYSTEMIZER_SPGFXA)
include $(SYSTEMIZER_SRC_PATH)/single_pass_GFx_abort/module.mk
endif

ifeq ($(SYSTEMIZER),SYSTEMIZER_SPEA_REDO)
include $(SYSTEMIZER_SRC_PATH)/single_pass_early_abort_redo/module.mk
endif
endif

SYSTEMIZERS =
SYSTEMIZERS += SYSTEMIZER_SPGF2
SYSTEMIZERS += SYSTEMIZER_SPGF2_REDO
SYSTEMIZERS += SYSTEMIZER_SPGFX
SYSTEMIZERS += SYSTEMIZER_SPGFXA
SYSTEMIZERS += SYSTEMIZER_SPEA_REDO

SYSTEMIZER ?= SYSTEMIZER_SPEA_REDO

