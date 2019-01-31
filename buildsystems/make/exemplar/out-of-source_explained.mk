#!/usr/bin/env -S make -f
#%SUMMARY: build in different dir from src, explained
#%

#%WARN: ".DEFAULT_GOAL" must be outside and above nested "ifeq-endif"
#%  => otherwise null-recipe "$(MAKEFILE_LIST)" will become default target
.DEFAULT_GOAL = all

#%NOTE: disable message Entering/Leaving directory
#%  <= impossible to disable only for nested make in second branch
MAKEFLAGS += --no-print-directory

#%NOTE: null-recipe is required for both branches of nested "ifeq-endif"
$(MAKEFILE_LIST): ;

#%NOTE: this/here is outside of "ifeq-endif" to allow $(here)-relpaths
#%  => it's better then env vars :: export SRCDIR := $(realpath ./src)
#%HACK: for relpath use $(shell realpath --relative-to=. '$(lastword $(MAKEFILE_LIST))')
#%  => but mostly we can live with "this" being abspath
this := $(realpath $(lastword $(MAKEFILE_LIST)))
here := $(patsubst %/,%,$(dir $(this)))

#%HACK: first branch is skipped when passing control to this makefile or doing "include"
ifeq ($(MAKELEVEL),0)

#%INFO:(no need to export): not the best solution, but sometimes useful for external scripts
# PATH := $(here)/exe:$(PATH)
#
#%BET: explicit relpaths to scripts -- and place them as prerequisites
# foo.md: foo.txt ./exe/converter.sh ; ./exe/converter.sh '$<' '$@'

#%WARN: can't disable disable implicit recipes and vars to pass control to nested ASAP
#%  => this var is exported and therefore becomes changed even for childs
# MAKEFLAGS += -rR --warn-undefined-variables

#%YELW! single letters are the best !
O := _build

#%MAYBE: using "$(here)/../src" is nice, but sometimes exporting is better
# export SRCDIR := $(realpath ./src)

#%BET: directly specify list of dirs allowed to be auto-created
#%ALT:BAD:SECU:(wrong paths not detected): unrestrainedly creates ANY directory passed as target
#%  %/ :: ; @mkdir -p '$@'
#%WARN: must use "mkdir -p" because together with "make -B" they will be "recreated"
#%WARN: use ':' single-colon rule, otherwise with '::' it will be rebuilt on each run
#%WARN: use '+' to dive into created directory even when --dry-run
#%HACK: use '/' to limit possible matching to directories only
$(O)/: ; +@mkdir -p '$@'

#%INFO: make first does "-C /path/to/dir" and then resolves "-f some.mk" relatively
#%  <= order of "-C" and "-f" is irrelevant, "-C" is always first
#%  !! always place "-C" first to not confuse others !!
#%WARN: "this" must be abspath or relpath-to "-C $(O)"
#%  => above you see "this" is resolved by $(realpath ...)
#%HACK: implicit recipes (e.g. '% ::') can't be made into .PHONY directly
#%  !! nested recipes with names equal to existing files won't be remade
.PHONY: .FORCE
% :: .FORCE | $(O)/
	+@$(MAKE) -C '$(O)' -f '$(this)' -- $(MAKECMDGOALS)
else

#%FAIL: can't reuse same var for different purpose NEED: two distinct vars (or same purpose)
#%  !! cmdline "make O=/path/to/_build" will overwrite and equate both of them !!
# O := _bin

#%HACK: special function to "shorten" paths in preview output of make
&at = $(shell realpath --relative-to=. '$(here)/$(strip $(1))')
d_src  := $(call &at,src)

#%BAD:PERF: searches every possible prerequisite inside VPATH
#%  [export] VPATH := ../src:/usr/local/lib/src
#%BET: search only chosen prefixes
vpath %.cpp $(d_src)

#%WARN: "vpath" will help only to "make"; help GCC yourself
vpath %.h $(d_src)
CPPFLAGS += $(addprefix -I,$(d_src))

#%NOTE: always rebuild keywords, even if file with same name exists
.PHONY: all

#%NOTE: we depend on the builtin recipes to compile binary from .cpp
#%  => therefore we can't do above "MAKEFLAGS += -rR"
all: main

endif
