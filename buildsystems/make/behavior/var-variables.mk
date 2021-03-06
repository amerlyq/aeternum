target:
	## Setup cmake variable in recipe
	$(eval O=build/$(@)/cmake)

	## Build cmake
	# $(CMAKE) -E chdir $(O) $(CMAKE) $(shell pwd)


# Use ordered-only prq to ignore dir's timestamp
# NOTE: works only when CACHE is the same dir (not template)
cmake/%: | $(CACHE)

$(CACHE):
	mkdir -p $(CACHE)

.SECONDEXPANSION:
# ALT:(SECONDEXPANSION) use macro + foreach
#   http://stackoverflow.com/questions/16267379/variables-in-makefile-prerequisites

# Extracting path part
_cache = $(subst /bin/$*,,$@)/cmake
$(PLTFS:%=$(O)/%/bin/%): $$(_cache)/Makefile
	$(MAKE) -C $(_cache)

# Keep resulting value unexpanded
foo_FLAGS = $a + $((5 + $a))
BAR = foo
$(info $(value $(BAR)_FLAGS))

# BAD: whole makefile -- single-thread (prms list not allowed)
.NOTPARALLEL:

# Default expansion (like bash ${x:-dfl_val})
trg_spec: tri := spec_val
trg_%: prereq_%
	echo "$(or $(tri),dfl_val)"

# Guard for empty vars in req*
#   OR: --warn-undefined-variables
t = $(or $(t_$(1)),$(error empty t_$(1)))
t_name := some/target
build: $(call t,name) ; echo $^
