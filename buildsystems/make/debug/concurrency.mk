#!/usr/bin/env -S make -rR --debug=jobs -j2 -f
#%SUMMARY: jobs demo
#%USAGE: $ ./strace-fork ./$0 | sort -t/ -k2n,2
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;

all: $(shell seq 1 5)

% ::
	echo "1| $$PPID/$*=$$$$" && sleep 0.8
	echo "2| $$PPID/$*=$$$$" && sleep 0.2
