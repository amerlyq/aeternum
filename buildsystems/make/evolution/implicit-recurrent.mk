#!/usr/bin/make -f
#%SUMMARY: evolution from zero (makefile running itself)
.DEFAULT_GOAL = all
this := $(lastword $(MAKEFILE_LIST))
$(this):: ;

ifeq (0,$(MAKELEVEL))
MAKEFLAGS += --no-print-directory

O := _build
export S := $(shell realpath --relative-to='$(O)' -- ./src)

$(O)/: ; +@mkdir -p '$@'
.FORCE :: | $(O)/
	+@$(MAKE) -C '$(O)' -f '$(realpath $(this))' -- $(MAKECMDGOALS)
% :: .FORCE ;
else

CXXFLAGS += -g -Wall -Werror
override CXXFLAGS += -I$(S)
vpath %.cpp $(S)

.SECONDARY:
.SUFFIXES:
.SUFFIXES: .o .cpp
%:: %.cpp
%:: s.%
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: SCCS/s.%

.PHONY: all
all: $(basename $(notdir $(wildcard $(S)/*.cpp)))

run-%: %
	./$<

clean:
	find . -mindepth 1 -delete
endif
