#!/usr/bin/make -sf
.ONESHELL:
.DEFAULT_GOAL = all
.SHELLFLAGS := -e -o pipefail -c
SHELL := $(shell which bash)
X = $(MAKE) -f $(lastword $(MAKEFILE_LIST)) line

# O=y/n - control assign override
# WARN! 'override VAR' will ignore 'make VAR=1' and wont export VAR to env !!!
override P := $(and $(filter-out 0 n,$(O)),override)

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
# WARN: all vars specified on make cmdline are exported!
# 	=> BUT:CHECK: only for old make<=4.0? No auto-export on v4.2.1
line: ; echo "$O:$T|$D|$S|$Q|$A||$$D|$$S|$$Q|$$A|" | tr -d ' '
all:
	{ echo "O:type|D|S|Q|A||=D|=S|=Q|=A|"

	  echo --- # Fetch
	  $X O=n
	  $X O=n T=arg D=1 S=1 Q=1 A=1
	  D=1 S=1 Q=1 A=1 $X O=n T=env
	  D=1 S=1 Q=1 A=1 $X -e O=n T="env-e"
	  D=1 S=1 Q=1 A=1 $X O=n T=both D=2 S=2 Q=2 A=2

	  echo --- # Override
	  $X O=y
	  $X O=y T=arg D=1 S=1 Q=1 A=1
	  D=1 S=1 Q=1 A=1 $X O=y T=env
	  D=1 S=1 Q=1 A=1 $X -e O=y T="env-e"
	  D=1 S=1 Q=1 A=1 $X O=y T=both D=2 S=2 Q=2 A=2

	} | column -ts'|' -o'|'


ifdef 0  ## Results:
# * Assign priority (ovrr > arg > env > val)
# * for args all simple assign w/o 'override' will be ignored (even +=)
# * after first 'override' only statements with 'override' work
# * (override ?= / +=) always queries/modifies
# * (override  = / :=) always reassigns
O:type |D  |S  |Q  |A   |
n:     |0+!|0+!|0+!|0+! | = inner assigns work until 1st 'override'
n:arg  |1! |1! |1! |1!  |
n:env  |0+!|0+!|1+!|10+!| = envs affect only explicit query and append, all
n:env-e|1! |1! |1! |1!  | = force envs, all assign ignored
n:both |2! |2! |2! |2!  | = args preffered over envs and vals

y:     |0! |0! |0! |0!  | = only statements with 'override' work
y:arg  |0! |0! |1! |10! |
y:env  |0! |0! |1+!|10! | = simple '+=' works only for explicit env query (unused '-e')
y:env-e|0! |0! |1! |10! | = 'override +=' actually works for enforced envs
y:both |0! |0! |2! |20! |
endif
