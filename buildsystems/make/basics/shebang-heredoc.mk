#!/bin/sh -eu
#%SUMMARY: do self-sourcing instead of self-execution
echo preparations...
exec make -f/dev/stdin "$@" <<'#EOF'
$(lastword $(MAKEFILE_LIST)): ;
all:
	echo hi
#EOF
