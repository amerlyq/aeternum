# EXPL:(file) generate file w/o invoking shell in recipe (expands to nothing)
# NOTE: when rules.mk will be constructed, make will re-execute whole Makefile
# BUT: re-excuting is performance hit for many $(shell ...) cmds
rules.mk: Makefile
	$(file > $@,) $(foreach T,$(TARGETS),$(file >> $@,$(RULE)))
-include rules.mk

## Derived prerequisites
define conf =
$(1)/origin: %/config/origin : %/$(2) | %/config
	cp -fT "$$<" "$$@"
endef
$(foreach c,$(CFG),$(eval $(call conf,$c,$(shell $(AUX)/get_prerequsite "$c"))))

## Chained prerequisites (prefixed / single make)
define conf =
$(LST:%=%/$(1)): %/$(1) : %/$(2)
	cp -fT "$$<" "$$@.in"
	conf_$(1) "$$@.in"
	mv -fT "$$@.in" "$$@"
endef
$(eval $(call conf,b,a))
$(eval $(call conf,c,b))
...

## Chained prerequisites (relative / recursive make)
cfg: ; mkdir -p "$@"
cfg/a: $(shell "$(AUX)/get_confnm" "$(PLTF)") | cfg
	cp -fT "$<" "$@"
cfg/b: cfg/a
cfg/c: cfg/b
cfg/%:
	cp -fT "$<" "$@.in"
	conf_$(@F) "$@.in"
	mv -fT "$@.in" "$@"

## Separate debug/release builds
NAME := $(if $(filter yes,$(DEBUG)),debug,release)
all: ; $(MAKE) $(NAME) -C $(NAME) -f ../Makefile DEBUG=

## Universal terminating rule
.SUFFIXES:
.SECONDEXPANSION:
% :: | $(O)/$$(firstword $$(subst /, ,$$@))
	+@$(MAKE) --no-print-directory -C $< -f $(shell pwd)/Makefile $(@:$(<:$(O)/%=%)/%=%)
