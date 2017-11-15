.PHONY: all
all: digestA

# EXPL: Don't rebuild if 'digestA' already exists, but not 'hugefile*'
#   http://stackoverflow.com/questions/23964228/make-ignoring-prerequisite-that-doesnt-exist
#   http://stackoverflow.com/questions/12199237/telling-make-to-ignore-dependencies-when-the-top-target-has-been-created
digestA: hugefileB hugefileC
	cat $^ > $@
	rm $^

# EXPL:
#  * if any of files deleted -- no rebuild of digestA
#  * any modified -- rebuilds digestA
#  * one deleted, another modified => rebuilds, re-creating deleted file, and keep it
.SECONDARY: hugefileB hugefileC
# OR .INTERMEDIATE: hugefileB hugefileC
# WARN: impossible to use pattern-match '.SECONDARY: hugefile%'
#   => pattern-match works only for '.PRECIOUS'
#   => ALT:BAD: empty '.SECONDARY:' to apply to all targets
#   SEE http://stackoverflow.com/questions/27090032/why-secondary-does-not-work-with-patterns-while-precious-does
#

hugefile%:
	touch $@

# EXPL:
#  * rebuild up-to-date targets when re-supplying new env vars to original Makefile
.INIT: some.h
.KEEP_STATE:
#   https://docs.oracle.com/cd/E19504-01/802-5880/6i9k05dhe/index.html
