.SUFFIXES:
# SEE http://make.mad-scientist.net/papers/multi-architecture-builds/
###################### Main ######################
# NOTE: can be extracted to '-include main.mk'
ifeq ($(MAKELEVEL),0)
O ?= _build
PLTF ?= linux windows android
.DEFAULT_GOAL = linux
# .DEFAULT_GOAL = all

.PHONY: $(PLTF) all
all: $(PLTF)
$(PLTF:%=$(O)/%): ; +@mkdir -p "$@"
$(PLTF): % : | $(O)/%
	+@$(MAKE) --no-print-directory -C "$|" -f "$(shell pwd)/Makefile" \
	  $(filter-out $(PLTF) $(PLTF:%=%/%),$(MAKECMDGOALS:$@/%=%)) \
	  |& tee "$(O)/$@/last.log" | tee -a "$(O)/$@/complete.log" \
	  ; exit $${PIPESTATUS[0]}
# ALT:(don't pass simple) $(patsubst $@/%,%,$(filter $@/%,$(MAKECMDGOALS)))
# NOTE: in general can't use $(shell pwd) -- if this file was included itself

# EXPL: suppress rule for usage $ make -f /path/to/Makefile
%/Makefile :: ;
Makefile: ;
%.mk :: ;
# OR:(~) .DEFAULT: ...
% :: $(.DEFAULT_GOAL) ;
$(foreach p,$(PLTF),$(eval $p/% :: $p ;))

# WARN: if targets contain '%' -> Make execs recipe only once to make them all!
# ALT: .SECONDEXPANSION:
# $(PLTF:%=%/%) :: $$(firstword $$(subst /, ,$$@)) ; @:
# BAD: manual targets don't appear in MAKECMDGOALS
# BAD: terminating rule '% ::' don't work for PHONY

else
##################### Target #####################
.DEFAULT_GOAL = all

PLTF := $(notdir $(shell pwd))
MWD := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
AUX := $(MWD)/bin

# WARN: exporting pollutes PATH for all subsequent toolchains !
export PATH := $(AUX):$(PATH)

all: build test
build:
	build_$(PLTF)

clean:
	@rm -vrf ./*
	@echo "clean: $(PLTF)"

.PHONY: all build clean
endif
