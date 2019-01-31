#!/usr/bin/env -S make -f
#%SUMMARY: hacks to substiture makefile control symbols
#%REF: escaping
#% * http://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
#% * https://www.gnu.org/software/make/manual/html_node/Syntax-of-Functions.html#Syntax-of-Functions
#%

# HACK:(concise):
, := ,
$(subst ,, ) := $(subst ,, )

# ALT:(verbose):
# comma := ,
# space :=
# space +=
# OR:
# empty :=
# space := $(empty) $(empty)
# OR:
# $() $() := $() $()

# ALSO:
equals := =
$(equals) := =
hash := \#
$(hash) := \#
colon := :
$(colon) := :
dollar := $$
$(dollar) := $$
; := ;
% := %

# USAGE:
paths := $(subst $( ),:,$(PATH))
