.PHONY: all
all: build

_build/CMakeCache.txt:
	mkdir -p _build
	cmake -B_build .

.PHONY: build
build: _build/CMakeCache.txt
	cmake --build _build

run:
	_build/main

.PHONY: clean
clean:
	rm -rf _build
