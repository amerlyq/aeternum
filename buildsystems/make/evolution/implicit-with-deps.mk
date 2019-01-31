#!/bin/sh -eu
#%SUMMARY: evolution from zero (additional auto-generated dependencies)
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
override CXXFLAGS += -MMD -I$(S)
vpath %.cpp $(S)

.SECONDARY:
.SUFFIXES:
.SUFFIXES: .o .cpp
%: %.cpp
%:: s.%
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: SCCS/s.%

.PHONY: all
srcs := $(notdir $(wildcard $(S)/*.cpp))
all: $(basename $(srcs))
include $(srcs:.cpp=.d)

# NICE: special search for libs paths
# REF: https://www.gnu.org/software/make/manual/make.html#Libraries_002fSearch
# foo : foo.c -lcurses
# 	cc $^ -o $@

run-%: %
	./$<

clean:
	find . -mindepth 1 -delete
endif
