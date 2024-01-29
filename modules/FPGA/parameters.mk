
# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 
ifndef PARAMETERS
PARAMETERS = 

PAR_SETS = \
	mceliece348864 \
	mceliece460896 \
	mceliece6688128 \
	mceliece6960119 \
	mceliece8192128

PAR_MODULE = \
	mceliece348864

define PARS_TEMPLATE =

ifeq ($(1), mceliece348864)
	id_$(1)= 1
	m_$(1) = 12
	t_$(1) = 64
	N_$(1) = 3488
	seed_$(1) = 13
	delta_$(1) = 0x319b3c7308adcf19c2d7924eff73bc5f52592340e16deed9a38ea12d080caf95
endif

ifeq ($(1), mceliece460896)
	id_$(1)= 2
	m_$(1) = 13
	t_$(1) = 96
	N_$(1) = 4608
	seed_$(1) = 4
	delta_$(1) = 0xc978c36081ed7f04c755d70cdc627326d59081b834ff9c8dcb210521441dc33b
endif

ifeq ($(1), mceliece6688128)
	id_$(1)= 3
	m_$(1) = 13
	t_$(1) = 128
	N_$(1) = 6688
	seed_$(1) = 4
	delta_$(1) = 0x240f0a4e7a1a2cf3f3c7756463f3e432805dd5bbd684cee56678dfa4acc54de1
endif

ifeq ($(1), mceliece6960119)
	id_$(1)= 4
	m_$(1) = 13
	t_$(1) = 119
	N_$(1) = 6960
	seed_$(1) = 4
	delta_$(1) = 0xf24587014785c4fce61329e4c5cc49a4f22da97c3521088c1f5b72ff968469d1
endif

ifeq ($(1), mceliece8192128)
	id_$(1)= 5
	m_$(1) = 13
	t_$(1) = 128
	N_$(1) = 8192
	seed_$(1) = 4
	delta_$(1) = 0x240f0a4e7a1a2cf3f3c7756463f3e432805dd5bbd684cee56678dfa4acc54de1
endif



BLOCK = 20 # matrix block size for computation in syndrome module

sec = 4 # number of multipliers used in twisting

factor = 0 # factor in add_FFT module

mul_sec_BM = 20 # number of multipliers inside vec_mul_multi in BM module

mul_sec_BM_step = 20 # number of multipliers inside vec_mul_multi in BM module

SIGMA1 = 16 # bit width of random number for poly gen

SIGMA2 = 32 # bit width of random number in sort module

M_H_elim = 1
ifneq ($$(t_$(1)), 5)
N_H_elim_$(1) = $$(t_$(1))
BLOCK_H_elim_$(1) = $$(t_$(1))
else
N_H_elim_$(1) = $$(m_$(1))
BLOCK_H_elim_$(1) = $$(m_$(1))
endif
#BLOCK_H_elim_$(1) = $$(shell echo $$(t_$(1))/2 | bc)

N_R_elim = 2
BLOCK_R_elim = 1

len_poly_mul_$(1) = $$(shell echo $$(t_$(1))/6+1 | bc)

len_koa_poly_mul_$(1) = $$(shell echo $$(len_poly_mul_$(1))*6 | bc)

x_$(1) = $$(shell echo $$(N_H_elim_$(1)) | bc)

mul_tot_$(1) = $$(shell $$(PYTHON) -c "from math import ceil; print(int(ceil($$(x_$(1)).0/$$(m_$(1)).0))*$$(m_$(1)))")

mul_cyc_$(1) = $$(shell $$(PYTHON) -c "from math import ceil; print(int(ceil($$(x_$(1)).0/$$(m_$(1)).0)))")

entrylen_$(1) = $$(shell $$(PYTHON) -c "import math; print(int($$(t_$(1))+1))")

t_mul_ceil_BM_$(1) = $$(shell $$(PYTHON) -c "import math; print(int(($$(t_$(1))+$$(mul_sec_BM))/$$(mul_sec_BM))*$$(mul_sec_BM))")
t_mul_ceil_BM_step_$(1) = $$(shell $$(PYTHON) -c "import math; print(int(($$(t_$(1))+$$(mul_sec_BM_step))/$$(mul_sec_BM_step))*$$(mul_sec_BM_step))")

num_$(1) = $$(shell $$(PYTHON) -c "import math; print(2**int(math.ceil(math.log(($$(t_$(1))+1), 2))))")
mem_width_$(1) = $$(shell $$(PYTHON) -c "import math; print(2**($$(factor)+$$(m_$(1))-1-int(math.ceil(math.log(($$(t_$(1))+1), 2)))))")

mem_width_keygen_$(1) = $$(shell $$(PYTHON) -c "import math; print(int(math.pow(2, ($$(factor)+$$(m_$(1))-math.ceil(math.log($$(t_$(1))+1, 2))))/2))")

endef

# Define all parameters globally
$(foreach par, $(PAR_SETS), $(eval $(call PARS_TEMPLATE,$(par))))
endif