#%SUMMARY: apply same rules to files at the current (different) cwd
#%USAGE: $ make -f $0 [args] [--] [tgts]
.DEFAULT_GOAL = all
$(MAKEFILE_LIST):;
all:
	echo hi
