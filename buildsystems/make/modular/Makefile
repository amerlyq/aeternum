.DEFAULT_GOAL = all
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;
.FORCE :: ;

ifeq ($(MAKELEVEL),0)
MAKEFLAGS += -rR --no-print-directory
export S := $(CURDIR)
O := _build
$(O)/: ; +@mkdir -p '$@'
.FORCE :: | $(O)/
	+@$(MAKE) -C '$|' -f '$(realpath $(this))' -- $(MAKECMDGOALS)
% :: .FORCE ;
else

# &at = $(shell realpath --relative-to='$(or $2,.)' '$(S)/$(strip $1)')

#%USAGE:
#% * [rebuild]: $ make @mods=aa -B
#% * [choosen]: $ make @mods='aa bb' install
# BET:(for recursive-sourcing): depend on "config.mk" which can be sourced
@mods := $(shell find '$(S)' -mindepth 2 -maxdepth 2 -xtype f -name Makefile -printf '%h\n')
@mods := $(notdir $(@mods))

.PRECIOUS: %/
%/: ; +@mkdir -p '$@'

DESTDIR := _install
prefix :=

.PHONY: all
all: build

# HACK: each "defcmd" can be considered as its own directory for extra-flat consistency
#   => then "make test" will be able to be smart about many things
#   NEED: export somehow list of its targets
#
# BAD? inconsistent because each *mod* can "make test" but main dir -- can only "cd test && make"
#   ALSO:XXX: what "cd test && make test" will even mean in this case ?
#
# MAYBE: simply make root Makefile also part of "system" like "airy" ?
#   => i.e place convenience scripts, etc. inside ./ctl/ dir and pass control from root into this dir
# !! consider root Makefile as "configurator" which provides required ifc for ./ctl/
#   export list of available @mods as ENV or FILE
#     ? maybe store list of mods in file "_build/@mods" and regen depending on dir itself timestamp ?
#       => don't use "_build/ctl/@mods" subdir because list itself is part of structure, not ./ctl/ program
#   change cwd := O=_build
#   some configuration vars ...
# >>> such "intermediate ifc" allows us to share and reuse same ./ctl/ for structures of other projects

define defcmd =
.PHONY: $(1)
$(1): --$(1)--
--$(1)--: $(@mods:=/--$(1)--)
	@touch -- '$$@'
%/--$(1)--: .FORCE | %/
	$(&make) '$(1)'
endef

# INFO: we could create inter-dep to guarantee test existance for ALL targets before running
# FAIL: it's useless, because "test" recipes itself may contain errors and will fail anyway
#   --test--: --build-test--
.PHONY: test
test: --test--
--test--: $(@mods:=/--test--)
	@touch -- '$@'
%/--test--: .FORCE | %/
	-$(&make) 'test'; echo $$? > '$@'

@cmds := build install test
&make := +$(MAKE) -C '$$|' -f '$(S)/$$*/Makefile' -- 'S=$(S)/$$*'
$(foreach 1,$(@cmds),$(eval $(call defcmd,$1)))


#%USAGE: build only chosen $ make aa
% :: .FORCE | %/
	$(&make)
endif
