#!/usr/bin/env -S make --silent -f
#%SUMMARY:
#% * Assign priority (ovrr > arg > env > val)
#% * for args all simple assign w/o 'override' will be ignored (even +=)
#% * after first 'override' only statements with 'override' work
#% * (override ?= / +=) always queries/modifies
#% * (override  = / :=) always reassigns
#%
.ONESHELL:
.DEFAULT_GOAL = all
.SHELLFLAGS := -e -o pipefail -c
SHELL := $(shell which bash)
X = $(MAKE) -f '$(lastword $(MAKEFILE_LIST))' line

# O=Y/n - control assign override
# WARN! 'override VAR' will ignore 'make VAR=1' and wont export VAR to env !!!
override P := $(and $(filter-out 0 N,$(O)),override)

# Fetch values from args/env
$(eval $(P) D  = 0)  # D - deffered eval
$(eval $(P) S := 0)  # S - set immediate
$(eval $(P) Q ?= 0)  # Q - query env
$(eval $(P) A += 0)  # A - append to env

# ATT:WARN: assign here works only for D/S/A in 'n:' and 'n:env'
# D  = 3
# S := 3
# Q ?= 3
# A += 3

D+=+
S+=+
Q+=+
A+=+

# NOTE: used to modify VAR catched from any arg/env/val
override D+=!
override S+=!
override Q+=!
override A+=!

# ATT:BAD: after override any simple assign won't work at all
D  = 4
S := 4
Q ?= 4
A += 4
D+=-
S+=-
Q+=-
A+=-

# T=aeEb - args passing type (arg/env/env -e/both)
# TODO:DEV: check with export/unexport for each case
#
#%WARN! cmdline vars are *ALWAYS* exported (inherited by all child programs)
#%  => prevent by using insignificant vars to pass values :: e.g. make sh=zsh | SHELL := $(key)
#%  [_] BUT:CHECK: only for old make<=4.0? No auto-export on v4.2.1
#%
line: ; echo "$$(echo "$O:$T|$D|$S|$Q|$A||$$D|$$S|$$Q|$$A" | tr -d ' ')| = $C"
all:
	{ echo "override|=|:=|?=|+=| |@=|@:=|@?=|@+=| [comments]"

	  echo --- # Fetch
	  $X O=N T=dflt                                  C="inner assign works until 1st 'override', empty in recipes"
	  $X O=N T=arg D=1 S=1 Q=1 A=1                   C="cmdline args overshadow everything beside 'override', empty in recipes"
	  D=1 S=1 Q=1 A=1 $X O=N T=env                   C="envs affect only explicit query and append, all"
	  D=1 S=1 Q=1 A=1 $X -e O=N T="env-e"            C="force envs, all assign ignored"
	  D=1 S=1 Q=1 A=1 $X O=N T=both D=2 S=2 Q=2 A=2  C="args preffered over envs and vals, exported envs are replaced by args"

	  echo --- # Override
	  $X O=Y T=dflt                                  C="only statements with 'override' work"
	  $X O=Y T=arg D=1 S=1 Q=1 A=1                   C="cmdline args are ignored unless queried by '?='"
	  D=1 S=1 Q=1 A=1 $X O=Y T=env                   C="simple '+=' works only for explicit env query (unused '-e')"
	  D=1 S=1 Q=1 A=1 $X -e O=Y T="env-e"            C="'override +=' actually works for enforced envs"
	  D=1 S=1 Q=1 A=1 $X O=Y T=both D=2 S=2 Q=2 A=2  C="cmdline again has priority, but not absolute"

	} | column -ts'|' -o'|'
