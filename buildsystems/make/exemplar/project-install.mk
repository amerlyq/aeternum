#%SUMMARY: clone and deploy gh-pages of current repo
#%
.POSIX:
.DEFAULT_GOAL = help
MAKEFLAGS += -rR --silent
this := $(lastword $(MAKEFILE_LIST))
here := $(patsubst %/,%,$(dir $(realpath $(this))))
.PHONY: $(shell sed -rn 's/^([A-Za-z0-9-]+):(\s.*|$$)/\1/p' '$(this)')

pkgname := dast
prefix := /usr/local
bindir := $(DESTDIR)$(prefix)/bin
libexecdir := $(DESTDIR)$(prefix)/lib
sharedir := $(DESTDIR)$(prefix)/share

dev:
	ln -svT 'bin/$(pkgname)' '$(bindir)/$(pkgname)'
	ln -svT 'bin/ds' '$(bindir)/ds'
	ln -svT 'lib' '$(libexecdir)/$(pkgname)'

undev:
	rm -v '$(bindir)/$(pkgname)' \
	  '$(bindir)/ds' \
	  '$(libexecdir)/$(pkgname)'

install:
	install -Dm755 'bin/$(pkgname)' '$(bindir)/$(pkgname)'
	cp -aT 'bin/ds' '$(bindir)/ds'
	install -d '$(libexecdir)'
	cp -aT 'lib/.' '$(libexecdir)/$(pkgname)'
	install -Dm644 LICENSE '$(sharedir)/licenses/$(pkgname)/LICENSE'
	install -Dm644 README.md '$(sharedir)/doc/$(pkgname)/README.md'


# SEE:(./xdotool/Makefile): https://github.com/jordansissel/xdotool
#   <= simplified packaging for .deb
