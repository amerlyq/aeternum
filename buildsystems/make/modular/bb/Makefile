this := $(lastword $(MAKEFILE_LIST))
here := $(patsubst %/,%,$(dir $(realpath $(this))))
&at = $(shell realpath --relative-to='$(or $2,.)' '$(here)/$(strip $1)')

--configure--:
	cmake '$(S)' -DCMAKE_BUILD_TYPE=RelWithDebInfo

.PHONY: build
build: --build--
--build--: --configure--
	+cmake --build .
	touch -- '$@'

.PHONY: install
install: --install--
--install--:
	+cmake --build . --target install
	touch -- '$@'
