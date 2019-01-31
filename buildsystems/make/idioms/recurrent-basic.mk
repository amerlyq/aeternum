#!/usr/bin/make -f
#%SUMMARY: dive into itself with additional actions
#%DEBUG: every time when unsure -- look into output of "make --debug=all"
#%NOTE: ".DEFAULT_GOAL" can be different in these branches
.DEFAULT_GOAL = aa
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;

$(info L=$(MAKELEVEL) C=$(C) E=$(E) | F: $(MAKEFLAGS) | O: $(MAKEOVERRIDES) | G: $(MAKECMDGOALS))

ifeq (0,$(MAKELEVEL))
MAKEFLAGS += -rR --no-print-directory
.FORCE :: ; +@$(MAKE) -f '$(this)' -- $(MAKECMDGOALS)
% :: .FORCE ;
else

aa bb cc:
	echo $@

endif
