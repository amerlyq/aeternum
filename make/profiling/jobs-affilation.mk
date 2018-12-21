#!/usr/bin/make -f
#%SUMMARY: demonstrate intermixed output w/o affiliation anchors
#%USAGE: $ ./$0 -j4 nested [-Otarget|-Orecurse]
#%ALSO:REF: https://www.cmcrossroads.com/article/pitfalls-and-benefits-gnu-make-parallelization
#%
.DEFAULT_GOAL = all
# SHELL := $(shell which bash)
# .SHELLFLAGS := -euo pipefail -c

# SHELL := $(shell which env) -- PS4='+ $$(date "+%s.%N")\011 ' $(shell which bash)
# .SHELLFLAGS := -euo pipefail -x -c

#
# .SHELLFLAGS := -euo pipefail -c 'echo "$$0 $$(date +%s.%N)"; time eval "$$@"' '$@'
MAKEFLAGS += -rR --print-directory
this := $(lastword $(MAKEFILE_LIST))
# inc_into := $(word $(words $(MAKEFILE_LIST)),_ $(MAKEFILE_LIST))
pr_shell := $(dir $(this))/shell-wrapper
# BAD: can't introduce any possible uuid through $(eval $(shell date +%s.%N)) due to recursive $(SHELL) usage
# BAD:ALSO: we have racing on global VAR UUID between links of chain :: $(eval...)$(warning...)$(shell)...
pfx_shell = $(warning $(UUID))
fn_shell = $(pfx_shell)env -- $(if $@,TGT='$@') $(if $?,NEW='$?') $(pr_shell)
SHELL = $(fn_shell)
# .SHELLFLAGS :=


# job-15: SHELL = $(pr_shell)

# pr_shell := $(SHELL)
# SHELL = $(warning [profiling] $@ $<)$(pr_time) $(pr_shell) -x

nested:
	$(MAKE) -C '$(dir $(this))' -f '$(this)' rec

all: $(shell seq -f 'job-%.f' 1 20)
rec: $(shell seq -f 'rec-%.f' 1 5)

rec-% ::
	$(MAKE) -C '$(dir $(this))' -f '$(this)' INST=$*

job-% ::
	echo '$(INST)=$$PPID/$*=$$$$'
	sleep 0.1
