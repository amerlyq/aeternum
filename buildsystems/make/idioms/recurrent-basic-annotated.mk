#!/usr/bin/env -S make -f
#%SUMMARY: dive into itself with additional actions


$(info L=$(MAKELEVEL) C=$(C) E=$(E) | F=$(MAKEFLAGS) | O=$(MAKEOVERRIDES) | G=$(MAKECMDGOALS))

ifeq (0,$(MAKELEVEL))
MAKEFLAGS += -rR --no-print-directory --warn-undefined-variables
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;

export E := 5
MAKEOVERRIDES += C=8

# BAD: can't hide msgs from lvl=0 only
# .SILENT: %
# MAKEFLAGS += --silent
# unexport MAKEFLAGS
#

# (2)
# BAD:(barrier): for second and next goals prints undesirable msg: {make: 'bb' is up to date.}
.PHONY: .FORCE
.FORCE ::
	+@$(MAKE) -f '$(this)' -- $(MAKECMDGOALS)
% :: .FORCE ;

else

aa bb cc:
	echo $@

endif
