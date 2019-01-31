#!/usr/bin/env -S make --no-print-directory -rRf
#%SUMMARY: different final match-anything terminal rules to pass on
.DEFAULT_GOAL = all
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;

V := 0

ifneq (0,$(MAKELEVEL))
% :: ; @sed -n '/^else .*,$V)$$/,/^$$/{/^#%/s/^#%/ * /p}' '$(this)'

# ------------------------------
else ifeq ($V,0)
# XXX? the best way ?

# ------------------------------
else ifeq ($V,1)
#%BAD: dives into recurrent make multiple times (once per each target)
#%FAIL: when passing multiple targets one-by-one -- you will lose virtual barriers from phony targets
.PHONY: .FORCE
% :: .FORCE
	+@$(MAKE) -f '$(this)' -- '$@'


# ------------------------------
else ifeq ($V,2)
#%OR: consider only after all intermediate implicit rules and ignore even tgts w/o recipe
.DEFAULT:
	+@$(MAKE) -f '$(this)' -- '$@'


# ------------------------------
else ifeq ($V,3)
#%BAD:(barrier): for second and next goals prints undesirable msg: {make: 'bb' is up to date.}
#%  => at least it's asymmetrical relatively to first goal
#%BAD:(pruning): tries to delete .FORCE on second and next goals: {Pruning file '.FORCE'.}
.PHONY: .FORCE
.FORCE ::
	+@$(MAKE) -f '$(this)' -- $(MAKECMDGOALS)
% :: .FORCE ;
# OR: $(.DEFAULT_GOAL) $(MAKECMDGOALS): .FORCE ;

# ------------------------------
else ifeq ($V,4)
#%BAD:(barrier): same problem as above (behaves the same when used with -rR)
.PHONY: .FORCE
%/:: ; +@mkdir -p $@
.FORCE: | $(O)/
	+@$(MAKE) -f '$(this)' -- $(MAKECMDGOALS)
%: .FORCE ;


# ------------------------------
else ifeq ($V,5)
#%FAIL: simply don't work, because prerequisites not supported here
.PHONY: .FORCE
.FORCE ::
	+@$(MAKE) -f '$(this)' -- $(MAKECMDGOALS)
.DEFAULT: .FORCE ;

# ------------------------------
else ifeq ($V,6)
#%NOTE: you don't need -- $(or $(MAKECMDGOALS),$(.DEFAULT_GOAL))
.DEFAULT_GOAL = .FORCE
$(MAKECMDGOALS) :: .FORCE
.PHONY: .FORCE
.FORCE ::
	+@$(MAKE) -f '$(this)' -- $(MAKECMDGOALS)

# ------------------------------
else ifeq ($V,7)
#%HACK: will be remade even with "--touch/--dry-run"
#%BAD: still produces {make: Nothing to be done for ...} but for all cmdline tgts
#%WARN: may be errorprone due to nesting even before makefile itself was remade
.DEFAULT_GOAL = $(this)
.PHONY: $(this) $(MAKECMDGOALS)
$(MAKECMDGOALS): $(this)
$(this): tgts := $(MAKECMDGOALS)
# MAKECMDGOALS :=
$(this):
	+@$(MAKE) -f '$(this)' -- $(tgts)

# ------------------------------
else ifeq ($V,8)
#%INFO: multiple results from single recipe
#%BAD: still asymmetrical {make: 'bb' is up to date.} ignoring first
.PHONY: .FORCE
.FORCE/%: .FORCE ;
tgts := $(or $(MAKECMDGOALS),$(.DEFAULT_GOAL))
$(tgts:%=%/%): .FORCE/%
	+$(MAKE) -f '$(this)' -- $(@:%/$*=%)
%: %/. ;

# ------------------------------
endif
