#!/usr/bin/env -S make -f
#%SUMMARY: phony target effects
#%  * demo with tracing and debugging
#%  * show effect of -rR on reducing debug log
#%USAGE: $ ./$0 [--trace|--debug={n|b|v|a|i,j,m}]
.PHONY: all
all: src/fileA src/fileB

# NOTE: simply defining phony tgt a1 is equivalent to noop recipe a2
.PHONY: a1
a2: ;


.PHONY: deps
deps: src/fileC

src/fileC:
	touch $@

# WARN: always executed, because .PHONY in req* always ignores timestamps
#  !!! => don't use phony as req* for non-phony (real file) targets
#  REF: http://bashdb.sourceforge.net/remake/make.html/Phony-Targets-Prerequisites.html
#  SEE: http://clarkgrubb.com/makefile-style-guide#phony-targets
#  ALT: use $(_req) VAR. BUT:BAD: no error if var with req* is empty!
src/fileA: deps
	touch $@

# HACK: order-only req* works normally even with .PHONY
src/fileB: | deps
	touch $@

# WARN:FAIL: make does not consider implicit rules for PHONY targets
.PHONY: src/impl.tgt
all: src/impl.tgt
%.tgt:
	echo implicit :: $*

#%HACK: implicit recipes can't be made .PHONY directly (e.g. %.mk, dir/%, '%')
#%  => use intermediate virtual file as prerequisite
.PHONY: .FORCE
% :: .FORCE | $(O)
