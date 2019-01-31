#%USAGE: | include $(TOP)/profiling.mk
#%USAGE: $ make --eval 'include $(TOP)/profiling.mk' ...
#%USAGE: $ export MAKE="make -f '$(realpath "$TOP")/profiling.mk'"
#%BET: patch buildroot make itself to print apply wait3(3) and print time for each recipe line
inc_into := $(word $(words $(MAKEFILE_LIST)),_ $(MAKEFILE_LIST))
pr_shell := $(dir $(lastword $(MAKEFILE_LIST)))/profiling-shell
fn_shell = env -- MK='$(inc_into)' $(if $@,TGT='$@') $(if $?,NEW='$?') $(pr_shell)
#%ALT:(only chosen targs): | $(prof_tgts): SHELL = $(fn_shell)
SHELL = $(fn_shell)
