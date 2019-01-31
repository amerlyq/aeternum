#!/usr/bin/env -S make -f Makefile -srRf
#%SUMMARY: how to prevent remaking of itself and included makefiles
#%NOTE: cmdline args "-f file.mk" are accumulated first
.DEFAULT_GOAL = recursive

#%INFO: trying to remake all makefiles occurs only once
#%  <= after reading all includes but before making goal itself

#%INFO: intitially VAR contains chain of all previously !read! makefiles
#%  => last element is current makefile
$(warning <INITIAL> $(MAKEFILE_LIST))

#%NOTE:(stub): suppress only the very last (this) makefile (using path as-is)
#%  <= prevents backward-propagation of suppression to parent makefile
#%  ATT: prevents "recipe override" warnings on "include"
$(lastword $(MAKEFILE_LIST)): ;

#%NOTE:ALT: use N last accumulated elements when placing after includes
include cwd-here.mk
$(lastword $(MAKEFILE_LIST)): ;

#%INFO: after each include VAR is appended (i.e. flat breadth-first instead of depth-first)
$(warning <AFTER> $(MAKEFILE_LIST))

#%ATT: optional "-include" must be suppressed explicitly (accumulated only when present/read)
-include myconfig.mk
myconfig.mk: ;

#%INFO: "optional" include appends only if it was found
$(warning <OPTIONAL> $(MAKEFILE_LIST))

#%WARN! nested makefiles won't inherit this list
recursive: export MAKEFILE_LIST := $(MAKEFILE_LIST)
recursive:
	+@$(MAKE) -f 'cwd-here.mk'
