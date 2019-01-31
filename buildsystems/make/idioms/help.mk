#!/usr/bin/env -S make --silent -f
#%SUMMARY: discoverability and self-documenting for makefiles
#%USAGE: $ ./$0 help-{phony,bbb,var}
#%BET:   $ remake --targets|--tasks

# ALT: https://gist.github.com/prwhite/8168133

this := (lastword $(MAKEFILE_LIST))

##############
help-selfdoc:
	@sed -rn '/^(.*\s)?#%/s///p' '$(this)'

PHONY := $(shell sed -rn 's/^([a-z]+):(\s.*|$$)/\1/p' '$(this)'|sort -u)
help-phony:
	@echo 'USAGE: $$ make [$(PHONY)]'

# REF: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile/45843594#45843594
help-annotated:
	@sed -rn '/^.PHONY:\s*(.*)?\s+#@\s(.+)/s// \1 - \2/p' '$(this)'

# REF: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile/26339924#26339924
help-recipes:
	+@$(MAKE) -pRrq -f '$(this)' : 2>/dev/null \
	  | awk -vRS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
	  | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

##############
.PHONY: all  #@ build all
all:
	echo hi
