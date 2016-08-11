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

## Separate debug/release builds
NAME := $(if $(filter yes,$(DEBUG)),debug,release)
all: ; $(MAKE) $(NAME) -C $(NAME) -f ../Makefile DEBUG=
