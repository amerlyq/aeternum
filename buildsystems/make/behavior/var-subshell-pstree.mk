#!/usr/bin/env -S make -f
#%SUMMARY: some lines in shell and some are not
#%USAGE: $ ./$0
#%ALT:SEE: ./self-run-strace.mk

# SEE: strace -f "=" -- which runs each time on VAR expansion
pid := $(shell echo $$PPID)
pstree = pstree -Uth '$(pid)'

all:
	$(pstree)
	$(pstree) && echo
	echo $$PPID && $(pstree)
	v=5; echo $$v; $(pstree)
	cd "$$PWD" && $(pstree)
	$(pstree) 2> /dev/null
	$(pstree) | cat
