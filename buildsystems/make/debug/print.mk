#!/usr/bin/env -S make --silent -f
#%SUMMARY: debug by printing
#%USAGE: $ ./$0 print-{aaa,bbb,var}
#%HACK:(external modify): $ make --eval='print-%: ; @echo $* = $($*)' print-{aaa,bbb}

aaa := 1
bbb := 2
var := 5

$(info var = $(var))
$(warning var = $(var))
ifeq ($(var),0)
$(error var = $(var))
endif

# HACK: tracing rules execution
# REF: https://www.cmcrossroads.com/article/tracing-rule-execution-gnu-make
pr_shell := $(SHELL)
SHELL = $(warning Building '$@'$(if $<, (from $<))$(if $?, ($? newer)))$(pr_shell)
.SHELLFLAGS := -xc

all:
	$(info var = $(var))echo hi

#%USAGE: $ make print-var
print-%: ; @echo '$*' = '$($*)'
# BUG: don't work $ ./print.mk var=0 pprint-var
pprint-%: ; $(info [$(flavor $*), $(origin $*)] $* = $($*))
