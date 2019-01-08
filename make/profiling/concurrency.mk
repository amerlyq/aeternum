#!/usr/bin/make -f
#%SUMMARY: test vars concurrency
#%USAGE: $ ./$0 -sj8 | sort -t/ -k2n,2
.DEFAULT_GOAL = all
MAKEFLAGS += -rR --no-print-directory

&savets = $(eval _prevts := $(shell date +%s.%N))

all: $(shell seq -f 'job-%.f' 1 20)

# XXX: still don't understand if vars are global or per-receipt thread
#  => they behave like thread-local i.e. ts before=after, but only first receipt VAR=0
export _prevts := 0
job-% ::
	echo "$$PPID/$*=$$$$" :: $(_prevts)
	$(&savets)sleep 0.2
	echo "$$PPID/$*=$$$$" :: $$(awk -vp='$(_prevts)' -vt="$$(date +%s.%N)" 'BEGIN{print p,"-",t,"=",t-p}')
