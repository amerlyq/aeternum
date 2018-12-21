#%USAGE: | include $(TOP)/profiling.mk
inc_into := $(word $(words $(MAKEFILE_LIST)),_ $(MAKEFILE_LIST))
pr_shell := $(dir $(lastword $(MAKEFILE_LIST)))/shell-wrapper
fn_shell = env -- MK='$(inc_into)' $(if $@,TGT='$@') $(if $?,NEW='$?') $(pr_shell)
#%ALT:(only chosen targs): | $(prof_tgts): SHELL = $(fn_shell)
SHELL = $(fn_shell)
