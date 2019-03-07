.DEFAULT_GOAL = build
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;

# TODO: logging into _log
# TODO: compose PREFIX_PATH from individual _install of all ext-deps
#   FAIL: need same SYSROOT / STAGING to allow linking by whole path
#   BET? do nothing for everything to fail in runtime to detect and allow only linking by relpaths

ifeq ($(MAKELEVEL),0)
MAKEFLAGS += -rR --no-print-directory
export S := $(CURDIR)
O := _build
$(O)/: ; +@mkdir -p '$@'
.FORCE :: | $(O)/
	+@$(MAKE) -C '$(O)' -f '$(realpath $(this))' -- $(MAKECMDGOALS)
% :: .FORCE ;
else

here := $(patsubst %/,%,$(dir $(realpath $(this))))
&at = $(shell realpath --relative-to='$(or $2,.)' '$(here)/$(strip $1)')

DESTDIR := _install
prefix :=
bindir := $(DESTDIR)$(prefix)/bin

include $(call &at,build.mk)

.PHONY: build
build: --build--
--build--:
	touch -- '$@'

# HACK: to introduce "check timestamp only if exists" use in each mod:
#   --install--: $(wildcard --build--)
# FAIL: --build-- will still check it's own prerequisites and will be rebuilt
#   * install -- must only install, without rebuild -- and fail if not possible
#   * build -- must only build
#   * build install -- must build first, then install
#   BET? --install--: $(patsubst %,--%--,$(filter build,$(MAKECMDGOALS)))

# MAYBE:ERR:(dep on PHONY): reverse-dependency to simplify user code
#   --install--: install

.PHONY: install
install: --install--
--install--: --install-bin--
	touch -- '$@'

--install-bin--:
	install -Dm755 -t '$(bindir)' $^
	touch -- '$@'

endif
