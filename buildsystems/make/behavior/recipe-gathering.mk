#!/usr/bin/env -S make -f
all: A/dev B/dev C/dev
reqA reqB reqC expl same part impl: ; $(info $@)

# Applied: all matching assigned (even repeated)
#  => identical rules -- in order they were defined
#  => heterogenous rules: % -- first, patt-% sorted, last explicit
A/dev: var += expl
A/%v:  var += part
A/%v:  var += repeat
A/de%: var += short1
A/d%:  var += short2
A/%:   var += same

# Combined: req* for explicit targets
A/dev: expl
# Not gathered: req* for implicit rules
#  <= because ALG drops all implicit rules w/o recipe
A/%:   same
A/%v:  part

A/%:
	$(info I: $^ :: $(var))


# Reversed situation -- has the same behavior
#  => no req* gathered, only VAR applied
B/%: var += impl
B/%: impl
B/dev:
	$(info E: $^ :: $(var))


# Gathered req* appended AFTER recipe's req*
#  => so in recipe you can deduce $< and $(word $n,$^)
#  : gathered req* are in the order of define
C/dev: reqA
C/dev: reqB
C/dev: reqC
	$(info $^)


# Chaining limitation (criteria to apply rule)
link: expA expB impA impB
# Recipe is unnecessary for any explicit rule (including .PHONY)
expA: expl
expB:: expl
# Recipe (at least empty one) is mandatory for implicit
#  <= because ALG drops all implicit rules w/o recipe
im%A: impl ;
im%B:: impl ;
