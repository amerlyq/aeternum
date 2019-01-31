#!/usr/bin/env -S make --no-print-directory --silent -f
#%SUMMARY: dive into itself with complex wrapper
#%
ifeq ($(MAKELEVEL),0)
.DEFAULT_GOAL = all
$(MAKEFILE_LIST): ;

# WARN:(don't work here): ${PIPESTATUS[0]}==0 due to {...} nesting in recipe
SHELL := $(shell which bash)
.SHELLFLAGS := -euo pipefail -c

# INFO: basic terminal colors
$(foreach n,$(shell seq 0 15),$(eval C$n := $(shell tput setaf $n)))
CR := $(shell tput sgr0 | rev | cut -c 2- | rev)
CB := $(shell tput bold)
CU := $(shell tput smul)
CI := $(shell tput sitm)

.PHONY: .FORCE
% :: .FORCE
	+{ { $(MAKE) -f '$(lastword $(MAKEFILE_LIST))' -- $(MAKECMDGOALS); \
	  } 3>&1 1>&2 2>&3 | sed -u 's/^/E: /'; \
	} 2>&1 | sed -u 's/\bE:/  $(CB)$(C1)&$(CR)/'
else

#%INFO!(nice): var SHELL is special -- never inherited and old env var is reused
#%  REF: https://www.gnu.org/software/make/manual/make.html#Choosing-the-Shell
$(info $(SHELL))
$(info $(.SHELLFLAGS))

all:
	echo yes
	echo no >&2
	false

endif
