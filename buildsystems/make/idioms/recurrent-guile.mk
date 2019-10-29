#!/usr/bin/make -f
#%SUMMARY: exec into make by using guile backdoor
#%
ifndef MAKEGUARD
$(subst ,, ) := $(subst ,, )
this := $(lastword $(MAKEFILE_LIST))
here := $(patsubst %/,%,$(dir $(this)))
# OR: envp := (append (environ) (list "MAKEGUARD=1" "MAKEFLAGS=$(MAKEFLAGS) --no-print-directory"))
envp := (let () (setenv "MAKEGUARD" "$(this)") (setenv "MAKEFLAGS" "$(MAKEFLAGS)") (environ))
args := $(subst \|,$( ),$(patsubst %,"%",$(subst \$( ),\|,$(MAKECMDGOALS) $(MAKEOVERRIDES))))
# MAKE := $(here)/scripts/make-wrapper
$(guile (execle "$(MAKE)" $(envp) "$(MAKE)" "--file=$(this)" $(args)))
else
unexport MAKEGUARD
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;

all:
	echo hi
endif
