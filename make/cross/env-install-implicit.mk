#!/usr/bin/make -srf
# FAIL: too complex dependencies -- no atomic scaling

# USAGE ./$0 -C /tmp/build_dir DESTDIR=/tmp/stage_dir
#   WARN: copy to DESTDIR w/o sudo
.DEFAULT_GOAL = all
MAKEFLAGS += -srR --warn-undefined-variables
SHELL := $(shell which bash)
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:
.SUFFIXES:
# BAD: no rebuild when deleted some ._*, can't delete dirs anyway
# ALT: .PRECIOUS: /tmp/_build/CommonAPI_3.1.5/._build
.SECONDARY:

this := $(lastword $(MAKEFILE_LIST))
$(this) : ;

# TEMP
O := /tmp/_build
# O := $(shell pwd)
DL := /sdk/buildroot/dl
DESTDIR ?= $(O)/_root
T := $(O)/CommonAPI_3.1.5

.PHONY: all
all: $(DESTDIR)/._$(notdir $(T))

.PHONY: clean
clean:
	rm -rf $(T)
	rm -f $(T).tar.gz
	# rm -f $(O)/CommonAPI_32bit_config.cmake

.PHONY: clean-all
clean-all: clean
	# BAD: no such "uninstall" -- use only global "clean-all"
	# $(MAKE) -C "$(T)/_build" uninstall
	rm -rf $(DESTDIR)

## ALT:
# .SECONDEXPANSION:
# %.tar.gz :: $(O)/$$(notdir $$@)).tar.gz | $(O)/
$(O)/%.tar.gz :: $(DL)/%.tar.gz
	mkdir -p "$(@D)"
	cp -fT "$<" "$@"

## WARN: if _build/ is outside extracted .tar.gz => delete _build/ folder too
%/._extract: %.tar.gz
	mkdir -p "$(@D)"
	tar -xvzf "$<" --recursive-unlink -C "$(@D)"
	# OR: rm -rf "$(@D)" &&
	touch "$@"


## BUG:(-m32): linking breaks on host g++
# %/_build/._configure: export CXXFLAGS+=-m32
# ALT:USAGE:
# 	cmake ... -DCMAKE_TOOLCHAIN_FILE=$(lastword $^)
# $(O)/CommonAPI_32bit_config.cmake:
# 	echo 'set(CMAKE_CXX_FLAGS "$${CMAKE_CXX_FLAGS} -m32" CACHE STRING "" FORCE)' > "$@"

%/_build/._configure: %/._extract $(this)
	mkdir -p "$(@D)"
	cmake -H"$(<D)" -B"$(@D)" -DCMAKE_INSTALL_PREFIX=$(DESTDIR)
	touch "$@"

%/._build: %/._configure
	$(MAKE) -C "$(<D)"
	touch "$@"

# OR: make DESTDIR="$(@D)" install
$(DESTDIR)/._%: $(O)/%/_build/._build
	$(MAKE) -C "$(<D)" install
	touch "$@"
