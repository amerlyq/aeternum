#!/usr/bin/env -S make --no-print-directory -f
#%SUMMARY: rerun targets from directory of script itself
#%WARN: beware about relative paths relocation
#%
ifeq ($(MAKELEVEL),0)
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;

this := $(lastword $(MAKEFILE_LIST))
here := $(patsubst %/,%,$(dir $(realpath $(this))))

.PHONY: .FORCE
% :: .FORCE
	+@$(MAKE) -C '$(here)' -f '$(this)' -- $(MAKECMDGOALS)
else

all:
	echo hi

endif
