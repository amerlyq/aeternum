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


# Multiple targets from one rule
## With common
%.out1 %.out2: %.input
    foo-bin $*.input $*.out1 $*.out2

## Completely different names (ALSO portable to non-GNU Make)
file-a.out file-b.out: input.in.intermediate
.INTERMEDIATE: input.in.intermediate
input.in.intermediate: input.in
    foo-bin input.in file-a.out file-b.out
