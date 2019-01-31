default: l64 w64 w32

# WARNING: bad organizing -- because if user manually create ./build dir
#   -- and launch cmake there -- results will be counterintuitive

# Defaults
PLT ?= l64
APP ?= cli

# Auxiliary
PWD := $(shell pwd)
O   := $(PWD)/build
AUX := $(PWD)/scripts

################## Platforms #####################
lX := l32 l64  # Linux
wX := w32 w64  # Windows
aX := a32 a64  # Android
# Bundles
uX := $(lX) $(aX)     # All unix-like
PLTFS := $(wX) $(uX)  # All generally
# Targets
l32t := i686-pc-linux-gnu
l64t := x86_64-pc-linux-gnu
w32t := i686-w64-mingw32
w64t := x86_64-w64-mingw32
a32t := arm-linux-androideabi
a64t := aarch64-linux-android
# Scripts
$(wX:%=%/%) $(wX:%=$(O)/%/%): PREFIX := $(AUX)/mingw-w64-
$(aX:%=%/%) $(aX:%=$(O)/%/%): PREFIX := $(AUX)/android-

################### Targets ######################
all: clean build
clean: ; rm -rf $(O)
build: $(PLTFS)
pkg: $(PLTFS:%=%/pkg)
# run: $(PLT)/run/$(APP)

$(PLTFS): % : %/build
$(PLTFS:%=%/build): %/build : $(O)/%/bin
$(PLTFS:%=%/cmake): %/cmake : $(O)/%/cmake/Makefile
$(PLTFS:%=%/clean): ; rm -rf $(O)/$(@D)
$(PLTFS:%=%/run): %/run : %/run/$(APP)
run/%: $(PLT)/run/%;

TSFX := cmake build run pkg clean
################### Recipes ######################
.SECONDEXPANSION:

## Common
# WARNING: we have deps on 'bin' directory and not actual bins!
#  -- so we can't continue partially successful builds
$(PLTFS:%=$(O)/%/bin): $(O)/%/bin : $(O)/%/cmake/Makefile
	$(MAKE) -C $(O)/$*/cmake

# .ONESHELL:
# --warn-unused-vars
$(PLTFS:%=$(O)/%/cmake): ; mkdir -p $@
$(PLTFS:%=$(O)/%/cmake/Makefile): %/Makefile : | %
	cd $* && \
	  TARGET=$($(@:$(O)/%/cmake/Makefile=%)t) \
	  $(PREFIX)cmake \
	  -Werror=dev -Wdev --warn-uninitialized \
	  -DCMAKE_INSTALL_PREFIX:PATH=../pkg \
	  $(PWD)

$(lX:%=%/install): %/install : $(O)/%/bin
	$(MAKE) -C $(O)/$*/cmake -- install/strip

## Dev
$(PLTFS:%=%/%): $$(subst /$$*,,$$@)/run/$$*;

# .SILENT:
_dir = $(O)/$(word 1,$(subst /, ,$@))

# TODO: to be able to run any 'exe' like test with args
#  -- make recipes in macro/function and call them by targets
$(lX:%=%/run/%): $$(_dir)/bin
	$(_dir)/bin/$*

$(wX:%=%/run/%): $$(_dir)/bin
	TARGET=$($(word 1,$(subst /, ,$@))t) \
	  $(PREFIX)wine \
	  $(_dir)/bin/$*.exe

## Test
$(lX:%=%/t): %/t : $(O)/%/bin
	@cd $(O)/$*/bin && \
	  ./$(APP)-t --gtest_color=yes

$(wX:%=%/t): %/t : $(O)/%/bin
	TARGET=$($(*)t) \
	  $(PREFIX)wine \
	  $(O)/$*/bin/$(APP)-t.exe --gtest_color=yes

## Package
# ALT:
#  $ cpack -G ZIP
#  $ cpack -DCPACK_GENERATOR="ZIP;TGZ;NSIS;NSIS64;IFW"
$(lX:%=%/pkg) $(wX:%=%/pkg): %/pkg : $(O)/%/bin
	cd $(O)/$*/cmake && \
	  cpack \
	  -DCMAKE_BUILD_TYPE:STRING="Release"

## Android
$(aX:%=%/apk): %/apk : $(O)/%/bin
	$(MAKE) -C $(O)/$*/cmake -- create-apk-qmain

$(aX:%=%/deploy): %/deploy : %/apk
	adb install -r $(O)/$*/pkg/qmain.apk

###################### Aux #######################
# CHECK:(by $ touch PHONY) if PHONY at the bottom is sufficient
PHONY := $(shell sed -rn 's/^([a-z-]+):(\s.*|$$)/\1/p' Makefile|sort -u|xargs)
PHONY += $(PLTFS) $(foreach t,$(TSFX),$(addsuffix /$t,$(PLTFS)))
.PHONY: $(PHONY)

help:
	@echo "Available targets: $(PHONY)"
