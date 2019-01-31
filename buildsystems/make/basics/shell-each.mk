#!/usr/bin/env -S make -f
#%SUMMARY: use different program for single recipe
#%USAGE: $ ./$0 [args] [--] [tgts]

# E.G. perl, python, etc
all: SHELL := echo
all: .SHELLFLAGS :=
all:
	hi
