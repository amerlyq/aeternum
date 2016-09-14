# USAGE: double-colon variants
alternate: double
explicit: explicit-only/some

req%: ; echo $@

## Alternate between ways to create target
#   * multiple recipes with requisites
#   ++ different recipes depending on which prerequisite caused the update
#   ?? such prerequisites must be in .SECONDARY
#     => then recipes won't be called if req* doesn't exists
#   !! FIND guard if target was already created/updated by previous ::rule
#     => priority to update target matches order of rules

## Split long multi-staged recipe with many req* in simpler ones
#   * gather ::recipes as parts of one big composed recipe
#   !! BUT on req* update only part of complete recipe will be executed!
#     => ATT stages must be unordered and associative!


## Double-colon rules
#  * when target doesn't exists -- ALL recipes executed in order of def
#  * any req* update -- triggers ALL respective recipes with older target
#  * each rule should specify recipe -> or implicit rule will searched
#    => ATT: it can undesirably sink into '% :: ...' terminal match-all
#  ! req* not collected -- and not combined
#  !! all recipes executed separately (just as different targets)
double :: reqA reqB  # ignored (no implicit rule+recipe)
double :: reqC
	@echo $^
	touch $@
double :: reqD
	@echo $^
	touch $@


## Single-colon rules
#  * collects all req*
#  ! last recipe overrides all previous
#  !! req* collected even from overriden recipes!
single: reqA reqB
single: reqC
	@echo $^
single: reqD
	@echo $^


## Mixed rules -- Error
# mixed: reqA reqB
mixed :: reqC
	@echo $^


## Double -- always rebuilds
#  ?? rule:: vs .PHONY:
#  USAGE: Distribute 'clean::' between multiple '*.mk' and execute all at once
#    => useful for auto-generated makefiles
#  BUT: impossible deps like 'clean: clean-mod', can't control recipes order
always ::
	@echo $@
# Single -- skips recipe if exists and up-to-date
once:
	@echo $@


## Restrict req* to explicit rules only
#  * target MUST BE pattern-matched
#  => inhibits chaining of intermediate targets in-between [f<(%.o<%.c)<f.c]
expA: ; echo $@
explicit-only/% :: expA reqA
	@echo $^
