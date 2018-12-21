#!/usr/bin/make -f
.PHONY: all
all: tgA tgB

.PHONY: req
req: deps
deps:
	touch $@

# WARN: always executed, because .PHONY in req* always ignores timestamps
#  !!! => don't use phony as req* for non-phony (real file) targets
#  REF: http://bashdb.sourceforge.net/remake/make.html/Phony-Targets-Prerequisites.html
#  SEE: http://clarkgrubb.com/makefile-style-guide#phony-targets
#  ALT: use $(_req) VAR. BUT:BAD: no error if var with req* is empty!
tgA: req
	touch $@

# HACK: order-only req* works normally even with .PHONY
tgB: | req
	touch $@

# WARN:FAIL: make does not consider implicit rules for PHONY targets
.PHONY: impl.all
all: impl.all
%.all:
	echo impl :: $*
