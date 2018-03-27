#%WARN: you can't change target type on the fly for same dir -- use "make clean"
#%
#%USAGE: $ make {AA|BB|host|gcc5|clang}[-1bcCdehloOOPrRTvvvX]
#% * chaining  $ make host test
.DEFAULT_GOAL = all
.NOTPARALLEL:
.SUFFIXES:
MAKEFLAGS += -rR --no-print-directory

### Constants
this := $(lastword $(MAKEFILE_LIST))
d_pj := $(dir $(this))
d_pj := $(d_pj:/=)
hosts := host gcc5 clang
boards := AA BB

### Parameters
broot := $(d_pj)
bpref := $(broot)/_build-
bdflt := $(or $(BOARD),host)
bflgs :=

### Defaults
all: $(bdflt)
clean: clean-$(bdflt)


##################################################
### Magic for builds
alltgts := $(boards) $(hosts)
$(boards:%=%-%) :: _bscript := $(d_pj)/scripts/build-arm
$(hosts:%=%-%) :: _bscript := $(d_pj)/scripts/build-host

## Magical targets, which pass choosen flags to underlying build script
# EXPL:(%-): for dash-targets use default debug flags (e.g. "B-" => "-1b")
#% * use -j1   $ make host-
$(alltgts:%=%-): %- : %-1b

# EXPL:(_btgt): use right side of name as flags (e.g. "B-Rcb" => "-Rcb")
#% * new build $ make host-Rcb
$(alltgts:%=%-%): _btgt = $(patsubst %-$(*F),%,$(@F))

# NOTE: exec "configure" once, but "build" runs always
#  => let cmake itself decide if some files have changed
# EXPL:(%-%): first % is substituted, second % is left as-is -- works as stem
#   => stem passed as flags to underlying script
$(alltgts:%=%-%) ::
	'$(_bscript)' '$(_btgt)' -B '$(_bdir)' $(or $(bflgs),-$(*F))


##################################################
### Magic for specials
## Gather all special generalized targets /smth-% ::/
specials := $(shell sed -rn 's/^([A-Za-z0-9-]+)-% ::(\s.*|$$)/\1/p' '$(this)'|sort -u|xargs)
# $(error $(specials))

# EXPL:(%-$(bdflt)): map short names to default targets "smth => smth-<default>"
$(specials): % : %-$(bdflt)

## ATT! without these two lines most of the Makefile magic won't work
# EXPL:(_btgt): use right side of name as target (e.g. clean-B => "B")
$(specials:%=%-%): _btgt = $(*)

# EXPL:(_bdir): build dir lazy fallback to prefixed name of currently derived target
_bdir = $(or $(bdir),$(bpref)$(_btgt))

# THINK: instead of "bdir" use target prefix dir $ make /some/dir/host-Rcb
#   => _bdir = $(or $(and $(findstring /,$*),$(*D)),...)
# BUG: pattern-specific var rule "host-%: _bdir=..." doesn't match /some/dir/host-Rcb"
#   => hack works only with prefix stem i.e. "%.o: _bdir=..."


##################################################
### Host specials
clean-% ::
	rm -rf --preserve-root $(_bdir)/

run-% ::
	$(abspath $(_bdir))/main/main

console-% ::
	$(abspath $(_bdir))/ctl/console

test-% ::
	$(abspath $(_bdir))/test/test

coverage-% ::
	$(MAKE) -C $(abspath $(_bdir))/test coverage-generate

dlt-daemon-% ::
	$(if $(BT_PREFIX_DIR),$(BT_PREFIX_DIR)/bin,$(abspath $(_bdir))/EP/dlt)/dlt-daemon

graph-cmake-% ::
	+@$(MAKE) -f '$(this)' '$(*F)' bdir='$(_bdir)' bflgs='-c -- --graphviz=_gv/g'
	find '$(_bdir)/_gv' -type f -name 'g*' -execdir mv {} {}.gv \;
	# dot -Tx11 '$(_bdir)/_gv/g.gv'


##################################################
### Target
# NOTE: if BOARD is set -- then it's whole firmware build + install
#   => otherwise it's developer's custom build (prevents accidental install on host)
#   * use $(BOARD) instead of $(ARCH) because we depend only on BOARD var
ifneq ($(BOARD),)
$(if $(BOARD),,$(error empty BOARD))
$(if $(ROOTFS),,$(error empty ROOTFS))

# DFL: build VERBOSE target rootfs image (to troubleshoot jenkins)
all: bflgs := -bv

# NOTE: append more prerequisites
all: external-pj/build/._build
clean: clean-external-pj

distclean: clean
install: all install-all
install-all: install-pj install-pj-test install-external-pj


##################################################
### Target specials
install-pj-% ::
	fakeroot cp -T $(_bdir)/main/main $(ROOTFS)/usr/bin/pj-main

install-pj-test-% ::
	fakeroot cp -T $(_bdir)/console/console $(ROOTFS)/usr/bin/pj-console
	fakeroot cp -T $(_bdir)/test/test $(ROOTFS)/usr/bin/pj-test


##################################################
### Organizer
external-pj/build/._build:
	./external-pj/build
	touch $@

install-external-pj:
	./external-pj/install

clean-external-pj:
	rm -rf --preserve-root external-pj/build/

endif


##################################################
### Helpers
PHONY := $(alltgts)
PHONY += $(shell sed -rn 's/^([A-Za-z0-9-]+):(\s.*|$$)/\1/p' '$(this)'|sort -u|xargs)
.PHONY: $(PHONY)
help:
	@echo "Targets: $(PHONY)"
	@echo "Specials: $(foreach s,$(specials),$s-%)"
	@sed -rn '/^(.*\s)?#%/s///p' '$(this)'


##################################################
### Magical one-time rules

# NOTE: use recursive cmake to prevent direct dependency on .PHONY target "%-c"
# EXPL:(*F): stem contains both dir and stem for implicit dependencies in subdirs
._configure.% ::
	+@$(MAKE) -f '$(this)' '$(*F)-c' bdir='$(*D)'
	touch $@

# ATT! place .SECONDEXPANSION prerequisites at the very bottom of Makefile
# 	=> reduce number of affected recipes
.SECONDEXPANSION:

# EXPL:(%): for simple targets use default build flags (e.g. "B" => "-b")
#% * withcmake $ make host
$(alltgts): \
  $(or $(bdir),$(bpref)$$@)/._configure.$$@ \
  $$@-b
