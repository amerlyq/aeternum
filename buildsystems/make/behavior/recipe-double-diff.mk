#!/usr/bin/env -S make -f
#%SUMMARY: difference between ":" vs "::" for -% targets
all: A

# v = A B C
# $(v:%=%-%):

# var := 1

D-% :: B-b ;

A-% :: var := 2

A-% B-% C-% :: -
gcc-% host-% ::

	echo ./script-arm '$(patsubst %-$(*F),%,$(@F))' '$(*F)' '$(var)'

gcc-% host-% ::
	echo ./script-host '$(patsubst %-$(*F),%,$(@F))' '$(*F)' '$(var)'

foo.o.c.a:

%.o: %.c
%.c: %.a
%.a:

foo: foo.o
foo: foo.c

foo.c: foo.c.o
foo.c: foo.c.c
foo.c: foo.c.p

# $ make foo bar
%: %.o

# <- foo.o
%.o : %.c
	gcc $< -o $@
# <- foo.c

%.c :: foo.c.in
	cpp $< -o $@

foo.c.in:
	sll

%.in:
	s..s.s.

foo.o :: foo.c
