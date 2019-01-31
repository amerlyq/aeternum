#!/usr/bin/env -S make -rR --no-print-directory -f
#%SUMMARY: multipurpose makefile
#%HACK:(one-file): config.mk + recurrent + controller
#%
ifneq (1,$(words $(MAKEFILE_LISTS)))
# config = sourced only after "include"
# HACK: can be reused from outside by simply sourcing

deps := aa bb cc
aa: bb
bb: cc

else ifeq (0,$(MAKELEVEL))
# proxy = main entry
# HACK: can be used directly from project directory
.DEFAULT_GOAL = .FORCE
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;
.PHONY: .FORCE
.FORCE ::
	+@$(MAKE) -f '$(this)' -- $(MAKECMDGOALS)
% :: .FORCE ;
else
# body = actual rules
# HACK: can be reused from outside for recursive makefiles calls
.DEFAULT_GOAL = aa
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;
include $(this)


$(deps):
	echo $@

endif
