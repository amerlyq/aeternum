#!/usr/bin/env -S make --no-print-directory -f
#%SUMMARY: passing variables into nested make

#%SECU:WARN! cmdline VARs exported by default (to be available in recursive make)
#%  https://www.gnu.org/software/make/manual/html_node/Variables_002fRecursion.html#Variables_002fRecursion
a := 0
$(info $(MAKELEVEL)=$(a) | $(MAKEOVERRIDES) | $(MAKEFLAGS))
# HACK: prevent options/vars from polluting nested make
# https://stackoverflow.com/questions/17050611/how-to-prevent-make-from-communicating-any-variable-to-a-submake
# https://www.gnu.org/software/make/manual/make.html#Options_002fRecursion

# FAIL: => no sence to do this -- cmdline vars will be exported anyway
#   BUT! it will override assinged vars and WONT import env if already recursive by others
#     => not useful, as you still must pass vars somehow even if from other makefiles
# BET: simply do :: export nm := main-dbg
E += nm=main-dbg
%: .FORCE
	+@$(MAKE) -f '$(lastword $(MAKEFILE_LIST))' -- '$@' $(E)

# WARN: "export" won't affect $(shell ...) -- only recipes are affected
export nm := main-dbg

# $(info $(.VARIABLES))

ifeq ($(MAKELEVEL),0)
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;
.PHONY: .FORCE
% :: .FORCE
	+@$(MAKE) -f '$(lastword $(MAKEFILE_LIST))' -- $(MAKECMDGOALS)
else

# NOTE: private global vars aren't accessible in recipes at all
private glob=2

# NOTE: private vars aren't inherited in prerequisites recipes
all: private my=3
all: our=4
all: some
	echo $(glob)/$(my)/$(our)

some:
	echo $(glob)/$(my)/$(our)

endif
