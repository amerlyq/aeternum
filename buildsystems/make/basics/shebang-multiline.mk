#!/bin/sh -eu
#%SUMMARY: additional preparations which are hard to express in "make"
:
	echo preparations...
	exec make -f "$0" "$@"

$(lastword $(MAKEFILE_LIST)): ;
all:
	echo hi
