#%WARN: you can't change target type on the fly for same dir -- use "make clean"
#%
#%USAGE: $ make {AA|BB|host|gcc5|clang}[-1bcCdehloOOPrRTvvvX]
#% * chaining  $ make host test
.DEFAULT_GOAL = all
MAKEFLAGS += -rR --no-print-directory
.NOTPARALLEL:
.SUFFIXES:
Makefile:;
$(subst ,, ) := $(subst ,, )

### Constants
this := $(lastword $(MAKEFILE_LIST))
d_pj := $(dir $(this))
d_pj := $(d_pj:/=)
hosts := host gcc5 clang
boards := AA BB

### Parameters
broot := $(or $(PJ_BUILD_ROOT),$(d_pj))
bpref := $(or $(PJ_BUILD_PREFIX),$(broot)/_build-)
bdflt := $(or $(PJ_BUILD_DEFAULT),$(HWTYPE),host)
bflgs :=

### Defaults
all: $(bdflt)
clean: clean-$(bdflt)


##################################################
### Magic for builds
alltgts := $(boards) $(hosts)
$(boards:%=%\ %): _bscript := $(d_pj)/scripts/build-arm
$(hosts:%=%\ %): _bscript := $(d_pj)/scripts/build-host

## Magical targets, which pass choosen flags to underlying build script
# EXPL:(%-): for dash-targets use default debug flags (e.g. "B-" => "-1b")
#% * use -j1   $ make host-
$(alltgts:%=%-): %- : %\ -1b

# ALT:TRY: use dedicated targets to tie flags for :: script_args (@-<flags>) and cmake_args (@@-<flags>)
# EXPL:(_btgt): use right side of name as flags (e.g. "B-Rcb" => "-Rcb")
#% NOTE: flags after minus are always required (can't use host" ..." or host-" ...")
#% * new build $ make host-Rcb
#% * pass args $ make host"-Rcb -DBUILD_TESTING=OFF"
$(alltgts:%=%\ %): _btgt = $(patsubst %|$(subst $( ),|,$(*F)),%,$(subst $( ),|,$(@F)))
# BAD: wrong if tgt name contains /-/     <= $(firstword $(subst -, ,$(@F)))
# BAD: wrong if tgt flags matches /-.*|/  <= $(subst -$(*F)|,,$(@F)|)
# BAD: wrong if tgt flags contain / /     <= $(patsubst %-$(*F),%,$(@F))

#%WARN: use space when adjacent flag contains '=', otherwise whole tgt is treated as env var
#% USE:(no additional '-' prepended):  $ make host"-DBUILD_TESTING"
#% BUT:(prepend space => not env var): $ make host" -DBUILD_TESTING=OFF"
$(alltgts:%=%\ %): _bflgs = $(or $(bflgs),$(*F))

# NOTE: exec "configure" once, but "build" runs always
#  => let cmake itself decide if some files have changed
# EXPL:(%-%): first % is substituted, second % is left as-is -- works as stem
#   => stem passed as flags to underlying script
# BUG: using '/' breaks parsing $ make gcc5"-ci -I/tmp/staging"
$(alltgts:%=%\ %):
	'$(_bscript)' '$(_btgt)' -B '$(_bdir)' $(_bflgs)


##################################################
### Magic for specials
## Gather all special generalized targets /smth-% ::/
specials := $(shell sed -rn 's/^([A-Za-z0-9-]+)-% ::(\s.*|$$)/\1/p' '$(this)'|sort -u|xargs)
# $(error $(specials))

# EXPL:(%-$(bdflt)): map short names to default targets "smth => smth-<default>"
$(specials): % : %-$(bdflt)
# BUG: spaces not allowed here MAYBE create explicit recipes for @-% ?
#   <= SEE(below):BAD: stem expanded and splitted before being interpreted
# MAYBE:BET: move flags logic from make to wrapper script and use make only for targets
#   i.e. wrapper chain (ctl -> Makefile -> build-host) -> cmake
#   ALT:USE: env vars e.g. CMAKE_ARGS, OR hide iterface completely, wrapping each of limited options
@-%: $(bdflt)-% ;

## ATT! without these two lines most of the Makefile magic won't work
# EXPL:(_btgt): use right side of name as target (e.g. clean-B => "B")
$(specials:%=%-%): _btgt = $(*F)

# EXPL:(_bdir): build dir lazy fallback to prefixed name of currently derived target
_bdir = $(or $(bdir),$(PJ_BUILD_DIR),$(bpref)$(_btgt))

# THINK: instead of "bdir" use target prefix dir $ make /some/dir/host-Rcb
#   => _bdir = $(or $(and $(findstring /,$*),$(*D)),...)
# BUG: pattern-specific var rule "host-%: _bdir=..." doesn't match /some/dir/host-Rcb"
#   => hack works only with prefix stem i.e. "%.o: _bdir=..."


##################################################
### Host specials
clean-% ::
	rm -rf --preserve-root $(_bdir)/

run-% ::
	$(abspath $(_bdir))/exe/exe

console-% ::
	$(abspath $(_bdir))/console/console

test-% ::
	$(abspath $(_bdir))/test/test

coverage-% ::
	$(MAKE) -C $(abspath $(_bdir))/test coverage-generate

dlt-daemon-% ::
	$(if $(BT_PREFIX_DIR),$(BT_PREFIX_DIR)/bin,$(abspath $(_bdir))/EP/dlt)/dlt-daemon

graph-cmake-% ::
	+@$(MAKE) -f '$(this)' \
	  '$(*F)' bdir='$(_bdir)' \
	  bflgs='-c -- --graphviz="$(_bdir)/_gv/g"'
	find '$(_bdir)/_gv' -type f -name 'g*' -execdir mv {} {}.gv \;
	# USE: dot -Tx11 '$(_bdir)/_gv/g.gv'

doxygen-% ::
	$(d_pj)/scripts/gen-doxygen '$(d_pj)' '$(_bdir)/_doxy'


## DEV
# strip-% ::
# deploy-flash-% ::


##################################################
### Target
# NOTE: if target-specific vars are set -- then it's whole firmware build + install
#   => otherwise it's developer's custom build (prevents accidental install on host)
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
install-all: install-pj-exe install-pj-test install-external-pj


##################################################
### Target specials
# CRIT! all pattern rules must be strictly distinct (one does not contain another)
#   i.e. using "install-pj-%" will wrongly catch "install-pj-test-%"

# BAD:SECU: undeserved root priviliges
#   $ sudo $(MAKE) -C '$(_bdir)' install
# BAD:CFG: on Jenkins under "sudo" PATH is different -> "cmake" may not exist or found outside cross-build
#   $ sudo cmake --build '$(_bdir)' --target install
# ALT:SECU: use "-DCMAKE_STAGING_PREFIX=$(_bdir)/_install" to override install() destination
#   and then use sudo only once recursively $ sudo cp -a '$(_bdir)/_install/.' '$(ROOTFS)/usr'
# BET:(only when {sudo -> fakeroot}):
#   $ cmake --build '$(_bdir)' --target install
install-pj-exe-% ::
	fakeroot cp -T $(_bdir)/exe/exe $(ROOTFS)/usr/bin/pj-exe

install-pj-test-% ::
	fakeroot cp -T $(d_pj)/scripts/run-tests $(ROOTFS)/usr/bin/pj-run-tests
	fakeroot cp -T $(_bdir)/console/console $(ROOTFS)/usr/bin/pj-console
	fakeroot cp -T $(_bdir)/test/test $(ROOTFS)/usr/bin/pj-test


##################################################
### Additionally aggregated external projects
external-pj/build/._build:
	./external-pj/build "$(@D)"
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

tags:
	$(d_pj)/scripts/gen-tags

tags-all:
	ctags -R

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

# TRY:TODO: build/run bdir with last timestamp (from multiple)
#   BAD:(impossible): name can be anything and dir placed anywhere
# IDEA use "$bdir/_rc.mk" to cache env vars and back-reference $pj/Makefile (may be useful for IDE)
#   i.e. all params not supplied explicitly by "make" or "env" must be queried from _rc.mk and saved back
#   BET: store inside "$pj/_build.config" -- because "$bdir" can be <anything>
#     DEV: parse cfg tgt "blast" variable
# @-%:
# %-@:

# NOTE: short alias <tgt>-<flags> to append cmdline w/o space delimiter
#   <= only [- ] delimiters are allowed (other symbols could be considered later)
# BAD: too complex, ugly to extend for other delimiters
# BUG: using '/' breaks parsing $ make gcc5"-ci -I/tmp/staging"
$(foreach t,$(alltgts),$(eval $t-% : \
	$t\$$$$( )-$$$$(subst $$$$( ),\ ,%) ;))
# BAD: stem expanded -> split prereq on space -> expand vars in prereq
# host-%: host\ -% ;
#   DEBUG: $ make --debug=a host"-R -DBUILD_TESTING=OFF"


# EXPL:(%): for simple targets use default build flags (e.g. "B" => "-b")
#% * withcmake $ make host
$(alltgts): \
  $(or $(bdir),$(bpref)$$@)/._configure.$$@ \
  $$@-b
