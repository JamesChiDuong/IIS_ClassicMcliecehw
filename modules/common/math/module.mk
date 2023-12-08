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
ifndef MATH

MATH_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# log2(x)
LOG2_SRC = clog2.v

# Galois Field
GF_MUL_SRC = gf_mul.v

GF_MAD_SRC = gf_mad.v

GF_SQ_SRC = gf_sq.v

GF_INV_SRC = gf_inv.v

# Polynomial Multiplication

POLY_MUL_REDUCED_SRC = poly_mul_reduced.v poly_red.v poly_mul_koa.v poly_mul_sb.v $(GF_MUL_SRC)

MATH_SRC = $(GF_MUL_SRC) $(GF_MAD_SRC) $(GF_SQ_SRC) $(GF_INV_SRC) $(LOG2_SRC)

MATH =

math: $(MATH)

define MATH_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
MATH_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(MATH_SRC))

# Collect all targets
MATH += $$(MATH_$(1))

GF_MUL_$(1): $$(BUILD_DIR_SRC_$(1))/gf_mul.v

GF_MAD_$(1): $$(BUILD_DIR_SRC_$(1))/gf_mad.v

GF_SQ_$(1): $$(BUILD_DIR_SRC_$(1))/gf_sq.v

GF_INV_$(1): $$(BUILD_DIR_SRC_$(1))/GFE_inv_syndrome.v

$$(BUILD_DIR_SRC_$(1))/gf_mul.v: $$(MATH_SRC_PATH)/gen_gf_mul.sage
	$$(SAGE) $$< --gf $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/gf_mad.v: $$(MATH_SRC_PATH)/gen_gf_mad.sage
	$$(SAGE) $$< --gf $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/gf_sq.v: $$(MATH_SRC_PATH)/gen_gf_sq.sage
	$$(SAGE) $$< --gf $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/gf_inv.v: $$(MATH_SRC_PATH)/gen_gf_inv.sage
	$$(SAGE) $$< -gf $$(m_$(1)) --name gf_inv > $$@

$$(BUILD_DIR_SRC_$(1))/clog2.v: $$(MATH_SRC_PATH)/gen_log2.py
	$$(PYTHON) $$< > $$@


$$(BUILD_DIR_SRC_$(1))/poly_mul_koa.v: $$(MATH_SRC_PATH)/gen_koa_poly_mul.py
	$$(PYTHON) $$< -n $$(len_koa_poly_mul_$(1)) --gf $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/poly_mul_sb.v: $$(MATH_SRC_PATH)/gen_sb_poly_mul.py
	$$(PYTHON) $$< -n $$(len_poly_mul_$(1)) --gf $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/poly_red.v: $$(MATH_SRC_PATH)/gen_poly_red.sage
	$$(SAGE) $$< -t $$(t_$(1)) --gf $$(m_$(1)) > $$@

$$(BUILD_DIR_SRC_$(1))/poly_mul_reduced.v: $$(MATH_SRC_PATH)/gen_poly_mul_reduced.py
	$$(PYTHON) $$< -n $$(len_koa_poly_mul_$(1)) -t $$(t_$(1)) --gf $$(m_$(1)) > $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call MATH_SRC_TEMPLATE,$(par))))

endif
