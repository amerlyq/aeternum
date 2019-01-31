#!/usr/bin/env -S make -f
#%SUMMARY: run whole recipe in single shell
#%USAGE: $ ./$0 [args] [--] [tgts]
.ONESHELL:

all: SHELL := python
all: .SHELLFLAGS := -c
all:
	import math
	v = math.sqrt(5)
	print(v)
	exit(1)
