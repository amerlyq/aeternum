#!/usr/bin/env -S sh -c 'mkdir -p "${O:=${0%/*}/_build}" && exec make -C "$_" -BrRf "$(realpath "$0")" "$@"'
#%SUMMARY: evolution from zero (augmented out-of-source build)
.DEFAULT_GOAL = run-main
S ?= ../src

CXX := g++
CXXFLAGS += -g -Wall -Werror
CXXFLAGS += -I$(S)

@src := $(wildcard $(S)/*.cpp)
@exe := $(@src:$(S)/%.cpp=%)

vpath %.cpp $(S)

all: $(@exe)

%: %.o
	$(CXX) $(LDFLAGS) -o $@ $^

#%NOTE: keep all implicit intermediate artifacts (otherwise deleted on exit)
#%ALT:(.PRECIOUS: %.o): supports patterns, but won't delete partially written *.o files
.SECONDARY:
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

run-%: %
	./$<

clean:
	find . -mindepth 1 -delete
