#!/usr/bin/make -f
# FAIL: too complex script, imperfect errors handling

# USAGE ./$0 DESTDIR=/tmp/stage_dir
#   WARN: copy to DESTDIR w/o sudo
.DEFAULT_GOAL = all
#################################################
MAKEFLAGS += -srR --no-print-directory
SHELL := $(shell which bash)
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:
.SUFFIXES:
.NOTPARALLEL:
this := $(lastword $(MAKEFILE_LIST))
mwd := $(realpath $(dir $(this)))
$(this) : ;

## BAD: error check is imperfect
#  * ignores mistyped vars in targets. E.G. $(deps:%=$(wrongname)): ...
#  * dry-run ignores mistyped vars in recepts
.PHONY: _check_makefile
_check_makefile:
ifndef _check_makefile
	+$(MAKE) -f $(this) --dry-run --warn-undefined-variables $(MAKECMDGOALS) _check_makefile=1 |& { ! command grep warning:; }
endif
#################################################
deps := CommonAPI \
  CommonAPI-D-Bus \
  dbus

DL := /sdk/buildroot/dl
export DESTDIR := /tmp/_root

# NOTE: "dep-pkgs.d" contains independent recipes
#   => build and install certain version of .tar.gz from $DL to $DESTDIR
markerpatt := $(DESTDIR)/._%
scriptpatt := $(mwd)/dep-pkgs.d/%

.PHONY: all
all: $(deps)

.PHONY: clean
clean: | _check_makefile
	rm -rf --preserve-root $(DESTDIR)/

$(DESTDIR)/:
	mkdir -p "$@"

.PHONY: $(deps)
$(deps): % : $(markerpatt)
$(deps:%=$(markerpatt)): $(markerpatt) : $(scriptpatt) | $(DL) $(DESTDIR)/ _check_makefile
	"$<" "$(DL)"
	touch "$@"
