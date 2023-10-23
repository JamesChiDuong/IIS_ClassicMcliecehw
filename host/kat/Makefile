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

# Avoid multiple includes
ifndef MCELIECE_KAT
export ROOT_PATH

MCELIECE_KAT = TRUE

KAT_SRC_PATH ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

MCELIECE_PKG = $(KAT_SRC_PATH)/mceliece/
MCELIECE_KATGEN = $(KAT_SRC_PATH)/kat.sage

MAKE ?= make
SAGE ?= sage


KAT_FILE_IRRED_RAND = irred_rand.kat
KAT_FILE_FIELDORDER_RAND = field_order_rand.kat
KAT_FILE_ERROR = error.kat
KAT_FILE_CIPHER_0 = cipher_0.kat
KAT_FILE_CIPHER_1 = cipher_1.kat
KAT_FILE_DELTA = delta.kat
KAT_FILE_DELTA_PRIME = delta_prime.kat
KAT_FILE_PUBKEY = pubkey.kat
KAT_FILE_POLY_G = poly_g.kat
KAT_FILE_P = P.kat
KAT_FILE_S = s.kat
KAT_FILE_K = K.kat
KAT_FILE_C = c.kat
KAT_FILE_SEED = mem_512.kat



KAT_FILES = \
	$(KAT_FILE_CIPHER_0) \
	$(KAT_FILE_CIPHER_1) \
	$(KAT_FILE_DELTA) \
	$(KAT_FILE_DELTA_PRIME) \
	$(KAT_FILE_PUBKEY) \
	$(KAT_FILE_POLY_G) \
	$(KAT_FILE_P) \
	$(KAT_FILE_S) \
	$(KAT_FILE_K) \
	$(KAT_FILE_SEED)

SLICED_PUBKEY_COLUMN_WIDTHS ?= 32 160

# Define public key name for specific slice width
KAT_FILES += $(foreach width, $(SLICED_PUBKEY_COLUMN_WIDTHS), \
	$(basename $(KAT_FILE_PUBKEY))_$(width)$(suffix $(KAT_FILE_PUBKEY)))

PAR_SETS ?= mceliece348864

KAT_DIR ?= .

CLEANING ?=

.PHONY: gen-kat

gen-kat: $(addprefix kat-, $(PAR_SETS))

.SECONDEXPANSION:

define KATGEN_TEMPLATE =

KAT_DIR_$(1) = $(KAT_DIR)
KAT_TARGETS_$(1) = $(addprefix $$(KAT_DIR_$(1))/,$(KAT_FILES))
CLEANING += $$(KAT_DIR_$(1))

.PHONY: kat-$(1)

kat-$(1): $$(KAT_TARGETS_$(1))

$$(KAT_TARGETS_$(1)): $(MCELIECE_KATGEN) | $$(KAT_DIR_$(1))
	$(MAKE) -C $(MCELIECE_PKG) sagelibs
	$(SAGE) $$< --generate \
	--pars $(1) \
	--kat-path $$(KAT_DIR_$(1)) \
	--slicewidths $(SLICED_PUBKEY_COLUMN_WIDTHS)

$$(KAT_DIR_$(1)):
	mkdir -p $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call KATGEN_TEMPLATE,$(par))))

# Preparse sagemath to python source code
%.py: %.sage
	$(SAGE) -preparse $<
	mv $(addsuffix .sage.py, $(basename $<)) $@

clean:
	rm -rf \
	$(ROOT_PATH)/host/kat/gat_generate

endif
