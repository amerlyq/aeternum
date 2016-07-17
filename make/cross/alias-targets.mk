default: b w/

# Defaults
PLT ?= linux-x86_64
CFG ?= debug
APP ?= cli

# Auxiliary
PWD := $(shell pwd)
O   := $(PWD)/build
AUX := $(PWD)/scripts/linux

CMAKE_ARGS := -Wdev --warn-uninitialized -Werror=dev  # --warn-unused-vars
################## Platforms #####################

DSFX  := debug release relwithdebinfo minsizerel
PLTFS := $(foreach p,linux windows,$(addprefix $p-,x86_64 i686)) android-arm android-aarch64
TARGS := $(foreach s,$(DSFX),$(addsuffix -$s,$(PLTFS)))

################### Targets ######################
all: clean build
clean: ; rm -rf $(O)
build: $(TARGS)
pkg: $(TARGS:%=%/pkg)
# run: $(PLT)/run/$(APP)

# BAD: broken
# $(TARGS): % : %/build
# $(TARGS:%=%/build): %/build : $(O)/%/bin
$(TARGS:%=%/cm): %/cm : $(O)/cmake/%/Makefile
$(TARGS:%=%/rm): ; rm -rf $(O)/cmake/$(@D)
# $(TARGS:%=%/r): %/r : %/run/$(APP)
# run/%: $(PLT)/run/%;

TSFX := cm rm pkg
################### Aliases ######################

# DEV: 'build' for each *-debug from 'default:'
# TRY: by replacing '-' to '/' -- sorting builds by subdirs
# build/cmake/$(PLTF)-$(arch)-$(CONFIG)
# DFL: x86_64-pc-linux-gnu i686-pc-linux-gnu

## Common
# $(info $$ ${1}    [${2}/${3}])
define t_custom
.PHONY: $(1) $(2)/$(3)
$(1): $(2)/$(3)
$(2)/$(3): $(O)/cmake/$(2)/Makefile
	$$(MAKE) -C "$$(<D)" $(3)
endef

define t_single
$(call t_custom,$(1),$(2),$(3))
$(call t_custom,$(1)/f,$(2),$(3)/fast)
endef

define t_group
$(call t_single,$(1)b,$(2),all)
$(call t_single,$(1)r,$(2),r-$(APP))
$(call t_single,$(1)g,$(2),t-$(APP))
$(call t_single,$(1)t,$(2),test-b)
$(call t_single,$(1)p,$(2),package)
endef

define t_config
$(call t_group,$(1)dbg/,$(2)debug)
$(call t_group,$(1)rel/,$(2)release)
$(call t_group,$(1)red/,$(2)relwithdebinfo)
$(call t_group,$(1)min/,$(2)minsizerel)
endef

define t_platf
$(call $(1),l/,linux-x86_64-$(2),$(3))
$(call $(1),ll/,linux-i686-$(2),$(3))
$(call $(1),w/,windows-x86_64-$(2),$(3))
$(call $(1),ww/,windows-i686-$(2),$(3))
$(call $(1),a/,android-arm-$(2),$(3))
$(call $(1),aa/,android-aarch64-$(2),$(3))
endef

# BUG: redefined recipes for partial targets
#  -- b, l/b, dbg/b -> l/dbg/b
define t_alias
$(call t_group,,$(PLT)-$(CFG))
$(call t_config,,$(PLT)-)
$(call t_platf,t_single,debug,all)
$(call t_platf,t_config,)
$(call t_platf,t_group,$(CFG))
endef

$(eval $(t_alias))
################### Recipes ######################
# .SECONDEXPANSION:

_tgt    = $(subst -, ,$(*:$(O)/cmake/%=%))
_prefix = $(AUX)/$(system)-$(arch)-
_exist  = $(if $(wildcard $(_prefix)$(1)),$(3)$(_prefix)$(1),$(if $(2),$(3)$(2)))

define _tgt_split
system := $(word 1,$(_tgt))
arch   := $(word 2,$(_tgt))
conf   := $(word 3,$(_tgt))
endef

$(O)/cmake/windows-%: toolchain := $(PWD)/cmake/linux/mingw32-w64.cmake
$(O)/cmake/android-%: toolchain := /usr/share/ECM/toolchain/Android.cmake

# BUG: CMake coredumps when -DCMAKE_CROSSCOMPILING_EMULATOR=""
$(TARGS:%=$(O)/cmake/%): ; mkdir -p "$@"
$(TARGS:%=$(O)/cmake/%/Makefile): %/Makefile : | %
	$(eval $(_tgt_split))
	cd "$*" && \
	  $(call _exist,cmake,cmake) $(CMAKE_ARGS) \
	  -DCMAKE_BUILD_TYPE="$(conf)" \
	  -DARCH:STRING="$(arch)" \
	  -DCMAKE_TOOLCHAIN_FILE:PATH="$(toolchain)" \
	  $(call _exist,emul,,-DCMAKE_CROSSCOMPILING_EMULATOR:PATH=) \
	  -DCPACK_OUTPUT_FILE_PREFIX:PATH="$(PWD)/build/pkg" \
	  -DCMAKE_INSTALL_PREFIX:PATH=pkg \
	  "$(PWD)"

###################### Aux #######################
PHONY := $(shell sed -rn 's/^([a-z-]+):(\s.*|$$)/\1/p' Makefile|sort -u|xargs)
PHONY += $(TARGS) $(foreach t,$(TSFX),$(addsuffix /$t,$(TARGS)))
.PHONY: $(PHONY)

help:
	@echo "Available targets: $(PHONY)"
