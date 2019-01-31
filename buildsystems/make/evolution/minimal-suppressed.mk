#!/usr/bin/make -Bf
#%SUMMARY: as small as possible (suppress excessive implicit rules)
.DEFAULT_GOAL = all
$(lastword $(MAKEFILE_LIST)): ;
.SUFFIXES:
.SUFFIXES: .cpp
.PHONY: all
all: src/minimal
%.cpp: ;
