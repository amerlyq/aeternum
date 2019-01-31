#!/usr/bin/env -S make -f
#%SUMMARY: use different program to execute all recipes
#%USAGE: $ ./$0 [args] [--] [tgts]

SHELL := echo
.SHELLFLAGS :=

#%WARN: changed shell will affect even $(shell ...) function
#%  => execute and catch all shell commands before changing interpreter
$(info $(shell date))

all:
	hi
