#!/usr/bin/env -S make --no-print-directory --silent -f
#%SUMMARY: dive into itself with exec wrapper
#%
# FIXME: fix according to out-of-source_explained
ifeq (0,$(MAKELEVEL))
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;
#%WARN: long PATH is BAD -- each command in each recipe will try each path until found
PATH := /usr/bin
.PHONY: .FORCE
% :: .FORCE
	+@strace -qqf -e signal=none -e trace=execve,write -- \
	  $(MAKE) -f '$(lastword $(MAKEFILE_LIST))' -- $(MAKECMDGOALS)
else

#%INFO: order of expansion
#% * whole makefile and all includes (and recipe-local vars)
#% * whole current recipe at once
#% * SHELL var before each individual line (command)

pr_shell := $(SHELL)
SHELL = $(file > /dev/stderr,$(eval counter+=x)$(words $(counter)))$(pr_shell)

all: var := $(shell true 0)
all:
	$(shell true 1)echo yes
	$(shell true 2)echo no >&2
	$(shell true 3)false

$(shell true end)

endif
