#%SUMMARY: clone and deploy gh-pages of current repo
#%
#%USAGE: full rebuild $ make build -B MAKE="make -o --clone--"
#%
.DEFAULT_GOAL = build
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;

here := $(patsubst %/,%,$(dir $(realpath $(this))))
&at = $(shell realpath --relative-to='$(or $2,.)' '$(here)/$(strip $1)')

ifeq ($(MAKELEVEL),0)
MAKEFLAGS += -rR --no-print-directory
O := _build
$(O)/: ; +@mkdir -p '$@'
.FORCE :: | $(O)/
	+@$(MAKE) -C '$(O)' -f '$(call &at,$(this),$(O))' -- $(MAKECMDGOALS)
% :: .FORCE ;
else


S := $(call &at,_site)
d_base  := $(call &at,..)
d_exe   := $(call &at,exe)
d_scheme:= $(call &at,src)
d_hooks := $(shell git rev-parse --git-dir)/hooks

msg     := $(shell date +'%Y%m%d_%H%M%S')
repourl := $(shell git remote get-url origin)
hosting := $(shell echo '$(repourl)' | sed -r 's|^.*:([^/]+)/(.*)|https://\1.github.io/\2|')
testing := http://localhost:4000/$(shell echo '$(repourl)' | awk '{print$$NF}')
browser := $(or $(shell which r.b 2>/dev/null),xdg-open)


clone: --clone--
--clone--: | $(S)/.nojekyll $(S)/.git/config
	touch -- '$@'


$(S)/.nojekyll: $(S)/.git/config
$(S)/.git/config:
	git clone '$(repourl)' --single-branch -b 'gh-pages' -- '$(S)'
	touch -- '$@'


hooks: --hooks--
--hooks--: $(d_hooks)/pre-push
	touch -- '$@'


$(d_hooks)/%: $(d_exe)/%.hook
	install -Dm755 '$<' '$@'


gems: --gems--
--gems--: Gemfile
	bundle update
	touch -- '$@'


# ALT: depend on all files (generate separate self-generated deps.mk file)
# ALT: $(file < all_md_from_nou)
# include 'deps.mk'
# deps.mk: $(@content)
#     $(file > $@.in) $(foreach 1,$^,$(file >> $@.in,--content--: $1))
#     mv -f -- '$@.in' '$@'
# $(file < cache.txt)


# BAD: multiple dirs will yield indistiguishable relpaths
content: --content--
@content := $(shell find '$(d_base)' -type f -path '*/ops/*.nou' -printf '%P\n')
$(@content): ;
--content--: $(@content:%.nou=%.md)
	touch -- '$@'


scheme: --scheme--
@scheme := $(shell find '$(d_scheme)' -type f -printf '%P\n')
--scheme--: $(@scheme)
	touch -- '$@'


$(@scheme:%=$(d_scheme)/%): ;
$(@scheme) : % : $(d_scheme)/%
	mkdir -p -- '$(@D)'
	cp -auT -- '$<' '$@'


vpath %.nou $(d_base)
%.md: %.nou \
 $(d_exe)/md-from-nou
	$(d_exe)/md-from-nou '$<' '$@' '$(*:$(d_base)/%=%)'


build: --build--
--build--:  --gems--  --content--  --scheme--  --clone--
	bundle exec jekyll build --safe --trace --source=. --destination='$(S)'
	touch -- '$@'


# INFO:(disable auto-gen): --no-watch --skip-initial-build
# CHECK:(sometimes does not rebuild): --incremental
# FAIL: can kill something inappropriate, must flock() and check that lock is still there
#   => maybe docker will be better ? e.g. https://github.com/aksakalli/jekyll-doc-theme/blob/gh-pages/Dockerfile
serve: --pid--
--pid--:  --stop--  --build--
	bundle exec jekyll serve --safe --trace \
	  --source=. --destination='$(S)' \
	  --skip-initial-build --watch --detach &> '$@.log'
	-rm -- '--stop--'
	grep -oP -- "detached with pid '\K\d+" '$@.log' > '$@.tmp'
	mv -f -- '$@.tmp' '$@'


# ALT: $ killall jekyll
# HACK: restart server by "make open -B", keep already running otherwise
#   :: prerequisite "--stop--" is ignored when "--pid--" already exists
.SECONDARY: --stop--
stop: --stop--
--stop--:
	-pkill -F '--pid--'
	-rm -- '--pid--' '--open--'
	touch -- '$@'


host open: --open--
host: url := $(hosting)
open: url := $(testing)
--open--: --pid--
	'$(browser)' '$(url)'
	touch -- '$@'


# BUG:(disastrous consequences): "_site" must be orphan git gh-pages branch
#   => let's hope having there ./.nojekyll is enough...
# RENAME? publish/push
deploy: --deploy--
--deploy--:  --clone--  --hooks--  --build--
	git -C '$(S)' add .
	git -C '$(S)' commit -m '$(msg)'
	git -C '$(S)' push origin gh-pages
	touch -- '$@'


# HACK: only if empty $ find '$(O)' -maxdepth 0 -type d -empty -delete
# HACK: keep old logs $ find '$(S)' -mindepth 1 -maxdepth 1 -name '_*' -prune -o -exec rm -rf {} +
# BAD: rm -rf --preserve-root '$(O)'
clean: --stop--
	find . -mindepth 1 -delete


# WARN: be very attentive to prevent your real files from becoming PHONY
PHONY := $(shell sed -rn 's/^([a-z]+):(\s.*|$$)/\1/p' '$(this)'|sort -u)
.PHONY: $(PHONY)
help:
	@echo 'USAGE: $$ make [$(PHONY)]'
	@sed -rn '/^(.*\s)?#%/s///p' '$(this)'
endif


# INFO: execute once -- only for new projects/repos/hosts
ifeq (1,$(INITNEW))
initial:
	# NEED: install "ruby-bundler"
	bundle install
	bundle exec jekyll new src
orphan: $(S)/.nojekyll
$(S)/.nojekyll: $(S)/.git/config
$(S)/.nojekyll $(S)/.git/config:
	git clone '$(repourl)' --single-branch -b 'master' -- '$(S)'
	git -C '$(S)' checkout --orphan gh-pages
	git -C '$(S)' rm -rf .
	touch -- '$@'
	git -C '$(S)' add '$@'
	git -C '$(S)' commit -m 'initial site commit'
	touch -- '$@'
endif
