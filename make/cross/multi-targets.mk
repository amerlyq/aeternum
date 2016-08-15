.SUFFIXES:
# SEE http://make.mad-scientist.net/papers/multi-architecture-builds/
###################### Main ######################
# NOTE: can be extracted to '-include main.mk'
ifeq ($(MAKELEVEL),0)
O ?= _build
PLTF := linux windows android

default: linux

Makefile: ;
%.mk :: ;
$(O)/% :: ; +@mkdir -p "$@"

.PHONY: $(PLTF)
$(PLTF): % : | $(O)/%
	+@$(MAKE) --no-print-directory -C "$|" -f "$(shell pwd)/Makefile" \
	  $(patsubst $@/%,%,$(filter $@/%,$(MAKECMDGOALS)))

.SECONDEXPANSION:
$(PLTF:%=%/%) :: $$(firstword $$(subst /, ,$$@)) ; :
else
##################### Target #####################
default: build test

PLTF := $(notdir $(shell pwd))
MWD := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
AUX := $(MWD)/bin
export PATH := $(AUX):$(PATH)

build:
	build_$(PLTF)

endif
