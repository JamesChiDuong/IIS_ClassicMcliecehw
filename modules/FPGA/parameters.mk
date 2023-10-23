
# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 
ifndef PARAMETERS
PARAMETERS = 

PAR_SETS = \
	Artycs324g

PAR_MODULE = \
	mceliece348864

define PARS_TEMPLATE =

ifeq ($(1), Artycs324g)
	id_$(1)= 1
	m_$(1) = 12
	t_$(1) = 64
	N_$(1) = 3488
	seed_$(1) = 13
	delta_$(1) = 0x319b3c7308adcf19c2d7924eff73bc5f52592340e16deed9a38ea12d080caf95
endif
ifeq ($(1), mceliece348864)
	id_$(1)= 1
	m_$(1) = 12
	t_$(1) = 64
	N_$(1) = 3488
	seed_$(1) = 13
	delta_$(1) = 0x319b3c7308adcf19c2d7924eff73bc5f52592340e16deed9a38ea12d080caf95
endif
endef
# Define all parameters globally
$(foreach par, $(PAR_SETS), $(eval $(call PARS_TEMPLATE,$(par))))
endif