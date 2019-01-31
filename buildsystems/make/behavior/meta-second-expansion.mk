#!/usr/bin/env -S make -f
#%SUMMARY: demo on second expansion
.DEFAULT_GOAL = B

a:
	echo $@

B: var := a

.SECONDEXPANSION:
B: $$(var)
	echo $@
