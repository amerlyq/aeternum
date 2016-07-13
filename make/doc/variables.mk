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


# BAD: whole makefile -- single-thread (prs list not allowed)
.NOTPARALLEL:
