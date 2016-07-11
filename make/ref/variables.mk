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
