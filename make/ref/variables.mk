target:
	## Setup cmake variable in recipe
	$(eval O=build/$(@)/cmake)

	## Build cmake
	# $(CMAKE) -E chdir $(O) $(CMAKE) $(shell pwd)
