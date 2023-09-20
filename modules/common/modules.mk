COMMON_SRC_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifndef MEMORY

MEMORY_SRC_PATH := $(COMMON_SRC_PATH)/memory


#include $(COMMON_SRC_PATH)/math/module.mk


MEMORY_SUBMODULES := LOG2

MEMORY_MEM_SRC = mem.v

MEMORY_SINGLE_SRC = mem_single.v

MEMORY_DUAL_SRC = mem_dual.v

MEMORY_SRC = $(MEMORY_SINGLE_SRC) $(MEMORY_DUAL_SRC)

MEMORY =

memory: $(MEMORY)

define MEMORY_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
MEMORY_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(MEMORY_SRC))

# Collect all targets
MEMORY += $$(MEMORY_$(1))

$$(BUILD_DIR_SRC_$(1))/mem.v: $$(MEMORY_SRC_PATH)/mem.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/mem_single.v: $$(MEMORY_SRC_PATH)/mem_single.v
	cp $$< $$@

$$(BUILD_DIR_SRC_$(1))/mem_dual.v: $$(MEMORY_SRC_PATH)/mem_dual.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call MEMORY_SRC_TEMPLATE,$(par))))

endif


ifndef SHAKE256

SHAKE256_SRC_PATH := $(COMMON_SRC_PATH)/shake256

SHAKE256_SRC = control_path.v  data_path.v  keccak_math.v  keccak_pkg.v  keccak_top.v rc.v  stateram_inference.v  state_ram.v  transform.v

SHAKE256 =

math: $(SHAKE256)

define SHAKE256_SRC_TEMPLATE =

# Define all required targets to be included in the modules above
SHAKE256_$(1) = $(addprefix $$(BUILD_DIR_SRC_$(1))/,$(SHAKE256_SRC))

# Collect all targets
SHAKE256 += $$(SHAKE256_$(1))

$$(BUILD_DIR_SRC_$(1))/%.v: $(SHAKE256_SRC_PATH)/%.v
	cp $$< $$@

endef

$(foreach par, $(PAR_SETS), $(eval $(call SHAKE256_SRC_TEMPLATE,$(par))))

endif


ifndef MATH

MATH_SRC_PATH := $(COMMON_SRC_PATH)/math

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