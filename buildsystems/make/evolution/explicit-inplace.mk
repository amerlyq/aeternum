#!/usr/bin/env -S make -rRBf
#%SUMMARY: evolution from zero (only explicit rules)
CXX := g++
CXXFLAGS += -g -Wall -Werror
CXXFLAGS += -I./src

exe := ./src/gradual
@src := \
	./src/main.cpp \

@obj := $(@src:.cpp=.o)

all: $(exe)

$(exe): $(@obj)
	$(CXX) $(LDFLAGS) -o $@ $^

$(@obj): %.o : %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

run: $(exe)
	./$<

clean:
	rm -f -- $(exe) $(@obj)
