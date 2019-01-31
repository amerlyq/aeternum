#!/usr/bin/env -S make --no-print-directory -f
#%SUMMARY: dive into itself with additional actions
#%WARN:NEED:
#  * [hardcoded goal]: otherwise first found rule will be implicit "remaking Makefile itself"
#  * [explicit recipe]: otherwise recurses multiple times due to "remaking Makefile itself"
#      ATT: when rarely using self-regenerated Makefile, this rule impedes regen in first branch
#  * [using FORCE]: otherwise files existing in current dir subpath will prevent remaking
#                   for targets with same names, even inside different dir of nested make(1)
#  * [prefix '+']: enable jobs server inheritance, don't trust $(MAKE) to work automatically
#
#
ifeq ($(MAKELEVEL),0)
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;
.PHONY: .FORCE
% :: .FORCE
	+@$(MAKE) -f '$(lastword $(MAKEFILE_LIST))' -- $(MAKECMDGOALS)
#%WARN: '%' have to be the last rule (make < v4.0)
#%  REF: https://www.gnu.org/software/make/manual/make.html#Match_002dAnything-Rules
#%ALT: .DEFAULT:
% :: .FORCE ;
else

aa bb:
	echo $@
endif
