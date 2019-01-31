#!/usr/bin/env -S make --no-print-directory --silent -f
#%SUMMARY: check by strace which lines in recipes run in shell, and which are not
#%USAGE: $ ./$0 [SHELL=/bin/echo]
#%WARN: always use single quotes '...' in recipes
#%  !! general rule -- never use spaces or "=", or many other special symbols in file names
#%  => even then there are valid files like 's*' or 'a$b' which will result in disaster
#%  SEE: $ ./$0 MAKELEVEL=1 --trace
#%
ifeq ($(MAKELEVEL),0)
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;

#%WARN: only shells which ends in 'sh' are simplified, otherwise interpreter is used always
SHELL := $(shell which bash)
.SHELLFLAGS := -euo pipefail -c

$(info $(SHELL))
$(info $(.SHELLFLAGS))

.PHONY: .FORCE
% :: .FORCE
	+@strace -f -e trace=%process -- \
	    $(MAKE) -f '$(lastword $(MAKEFILE_LIST))' $(MAKECMDGOALS) \
	  |& grep -E '\b(execve)\(' \
	  | grep -vw ENOENT \
	  | sed 's/^.*]\s//; s/\w*("//; s/"\?\],\s.*$$//; s/\["/"/; s/", "/\t/g' \
	  | column -ts$$'\t' -o$$'|'
else

var_space  := a b
var_escape := a\ b
var_quote  := 'a b'
var_expand := wra$$th
var_glob   := wra*

all:
	echo yes
	echo yes && echo
	echo 'yes'
	echo "yes"
	echo '$$PWD'
	echo "$$PWD"
	echo 'key=value'
	echo key='value'
	cd "$$PWD" && pwd
	v=5; echo $$v
	printf '%s\n' $(var_space) $(var_escape) $(var_quote)
	printf '%s\n' $(var_expand) $(var_glob)
	printf '%s\n' '$(var_space)' '$(var_escape)' '$(var_quote)'
	printf '%s\n' $(var_space) >&2
	printf '%s\n' $(var_escape) | cat

endif
