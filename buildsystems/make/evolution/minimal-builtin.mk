#!/usr/bin/env -S make src/minimal -rRBf
#%SUMMARY: as small as possible (built-in rules revealed)
#%  SEE: $ make -f/dev/null --print-data-base

CXX = g++
OUTPUT_OPTION = -o $@

LINK.cc = $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)
LINK.cpp = $(LINK.cc)
%: %.cpp
	$(LINK.cpp) $^ $(LOADLIBES) $(LDLIBS) -o $@


COMPILE.cc = $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.cpp = $(COMPILE.cc)
%.o: %.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

CC = cc
LINK.o = $(CC) $(LDFLAGS) $(TARGET_ARCH)
%: %.o
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@
