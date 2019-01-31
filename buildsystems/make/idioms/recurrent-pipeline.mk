#!/usr/bin/env -S make --no-print-directory --silent -f
#%SUMMARY: dive into itself with pipeline wrapper
#%WARN:(bash only): "${PIPESTATUS[0]}" -- empty in ZSH, error in POSIX
#%  !!! BAD: no err, when pipe had failed in the middle segment (e.g. 2nd or 3)
#%
ifeq ($(MAKELEVEL),0)
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;

d_log := /tmp/$(LOGNAME)
f_log := $(d_log)/$(shell date +'%Y%m%d_%H%M%S').log
$(info $(f_log))

.PHONY: .FORCE
% :: .FORCE
	+@$(MAKE) -f '$(lastword $(MAKEFILE_LIST))' -- $(MAKECMDGOALS) \
	  2>&1 | stdbuf -oL -eL tee -a '$(f_log)' \
	  ; exit "$${PIPESTATUS[0]}"
else

all:
	echo yes
	echo no >&2
	false

endif
