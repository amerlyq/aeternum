#!/usr/bin/env -S make --silent -f
#%SUMMARY: find dir of mk file to access relative paths
#%USAGE: $ ./$0 [args] [--] [tgts]

this := $(lastword $(MAKEFILE_LIST))
here := $(patsubst %/,%,$(dir $(realpath $(this))))

$(warning <NESTED> $(MAKEFILE_LIST))

all:
	pwd
	echo this=$(this)
	echo here=$(here)
