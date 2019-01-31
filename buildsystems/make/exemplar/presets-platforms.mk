#!/usr/bin/env -S make -f
#%SUMMARY: build in different dir from src
#%WARN! always build only single platform in main body !
#%
.DEFAULT_GOAL = help
MAKEFLAGS += --no-print-directory

this := $(lastword $(MAKEFILE_LIST))
here := $(patsubst %/,%,$(dir $(realpath $(this))))
$(this): ;


ifeq (0,$(MAKELEVEL)) ################################################
.SUFFIXES:
O := _build
.PRECIOUS: $(O)%/
$(O)%/: ; @mkdir -p '$@'


#%NOTE: by analogy you can also create platforms "arm: arm/debug: ..."
#%WARN: don't do more then single level of nesting -- flatten usecases
#%BET! use only plain assigns here -- MOVE! conditional choices into recurrent branch

.PHONY: debug
debug: build
debug: O := $(O)-debug
debug: export nm := main-dbg
debug: export CXXFLAGS += -g

# BET? instead of export -- pass them on cmdline below
.PHONY: release
release: build
release: O := $(O)-release
release: MAKEFLAGS += nm=main
# release: MAKEOVERRIDES += nm=main

# ATT! obscure example to frighten the shit out
# .SECONDEXPANSION:
# auto: DEBUG := 1
# auto: export O := $(O)/$$@$$(if $$(DEBUG),-debug)
# auto: export CXXFLAGS += $$(if $$(DEBUG),-g)
# auto: export nm := $$@-dbg
# auto: build


.SECONDEXPANSION:
.PHONY: .FORCE
%: .FORCE | $$(O)/
	+@$(MAKE) -C '$(O)' -f '$(realpath $(this))' -- '$@'
else #################################################################
.SUFFIXES: %

nm := main

&at = $(shell realpath --relative-to=. '$(here)/$(strip $(1))')
d_src  := $(call &at,src)

vpath %.cpp $(d_src)
vpath %.h $(d_src)
CPPFLAGS += $(addprefix -I,$(d_src))

run: $(nm)
	./$<

.PHONY: build
build: $(nm)

clean:
	rm main

endif
