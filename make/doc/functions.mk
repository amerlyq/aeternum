## Functions

# use success result in condition
distro = $(shell grep -isqF $(1) /etc/os-release /etc/lsb-release || echo $$?)
ifeq ($(call distro,arch),)
env-setup:
	pacman -S cmake
endif

# Debug
define t_custom
$(info $$ ${1} -- [${2}/${3}])
$(1): $(2)/$(3)
endef
$(call t_custom,b,trg,dbg)
