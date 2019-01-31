#!/usr/bin/env -S make -f
#%SUMMARY: build in different dir from src
#%
.DEFAULT_GOAL = aaa
MAKEFLAGS += --no-print-directory
$(lastword $(MAKEFILE_LIST)): ;
$(info $(MAKEFILE_LIST))

this := $(realpath $(lastword $(MAKEFILE_LIST)))
here := $(patsubst %/,%,$(dir $(this)))

ifeq ($(MAKELEVEL),0)
O := _build
$(O)/: ; +@mkdir -p '$@'
.PHONY: .FORCE
% :: .FORCE | $(O)/
	+@$(MAKE) -C '$(O)' -f '$(this)' -- $(MAKECMDGOALS)
else

&at = $(shell realpath --relative-to=. '$(here)/$(strip $(1))')
d_src  := $(call &at,src)

vpath %.cpp $(d_src)
vpath %.h $(d_src)
CPPFLAGS += $(addprefix -I,$(d_src))

aaa: main
	touch $@

.PHONY: all
all: main
clean:
	rm main

endif
