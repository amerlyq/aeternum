#!/bin/sh -eu
#%SUMMARY: evolution from zero (out-of-source simplified by built-ins)
:
	mkdir -p "${O:=${0%/*}/_build}"
	exec make -C "$_" -f "$(realpath $0)" --no-print-directory -B "$@"

.DEFAULT_GOAL = run-main
$(lastword $(MAKEFILE_LIST)): ;

S ?= ../src

CXXFLAGS += -g -Wall -Werror
override CXXFLAGS += -I$(S)
vpath %.cpp $(S)

#%NOTE! sometimes it's better to simply copy default recipes...
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
all: $(basename $(notdir $(wildcard $(S)/*.cpp)))

run-%: %
	./$<

clean:
	find . -mindepth 1 -delete
