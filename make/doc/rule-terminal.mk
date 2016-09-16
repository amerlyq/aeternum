all: prf1 prf2

## Dummy
.SUFFIXES:
# EXPL: suppress rule for usage $ make -f /path/to/Makefile
%/Makefile :: ;
Makefile :: ;
%.mk :: ;


## Terminal rules::
#  * not apply unless its prerequisites actually exist.
#  * ignores req* which can be made by other implicit rules
reqA: ; echo $@  # explicit -- executed after terminal
req%: ; echo $@  # implicit -- ignored (no further chaining)
# % :: req% ; # (demo) stop chaining


## Dispatching prefixed targets
prf1 prf2: ; echo "$@ => $(MAKECMDGOALS)"
prf1/% :: prf1 ;
prf2/% :: prf2 ;
% :: all ; echo "$@ :: $^"  # terminal match-anything


# Non-terminal match-anything rule
#   * cannot apply to a file name that indicates a specific type of data
#     <= if some non-match-anything implicit rule target matches it
# %: all ;
