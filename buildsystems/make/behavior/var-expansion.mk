#!/usr/bin/env -S VAR='$($(bi))' make --silent --warn-undefined-variables var='$(bi)' -f
#%SUMMARY: variables composition piece-by-piece

a := some.h
bi := a
c := b
d := i

all:
	echo 1 $a     # avoid it, beside $$(foreach ...)
	echo 2 $(a)
	echo 3 ${a}   # avoid it, (for Lisp-like consistency, banned in MS NMake anyway :)
	echo 4 $bi    # error, catched by --warn-undefined-variables
	echo 5 $(bi)
	echo 6 $($(bi))
	echo 7 $($($(c)$(d)))
	echo 8 $(var)   #%SECU:WARN! values (both env and cmdline) are *ALWAYS* expanded (lazy assigned)
	echo 9 $(VAR)   #%  !! even prerequisite path like "somepath$(yes)path" will be expanded !!
	echo 0 $${var}  #%SECU:WARN! cmdline vars ($ make a=5) are exported by default (to be available in recursive make)


# WARN:(--warn-undefined-variables): not panacea, sometimes you NEED undefined variables
# SEE: https://www.gnu.org/prep/standards/html_node/Directory-Variables.html
install:
	install -Dm755 mybin '$(DESTDIR)$(prefix)/bin'
	install -Dm644 mydata '$(DESTDIR)$(prefix)/lib/$(pkgname)'
