#!/usr/bin/env -S make -f
#%SUMMARY: rebuild single target chain up
#%USAGE: $ make -W

#%WARN: flags [-W/-o tgt] work for main make instance only
#%HACK: pass old/new targets into nested self-run make
#%  $ make -- MAKE="make -W _bbb"
#%
#%ALT: rebuild single recipe AND all its dependencies beside marked OLD
#%  $ make -B -o "--gems--" -- tgt

_aaa: _bbb
	touch $@

_bbb:
	touch $@
