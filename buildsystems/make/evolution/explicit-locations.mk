#!/usr/bin/env -S make -rRBf
#%SUMMARY: evolution from zero (distint build / src dirs)
O := _build
S := src
exe := gradual

CXX := g++
CXXFLAGS += -g -Wall -Werror
CXXFLAGS += -I$(S)

@src := \
	main.cpp \

@obj := $(@src:%.cpp=$(O)/%.o)

all: $(O)/$(exe)

$(O)/$(exe): $(@obj)
	$(CXX) $(LDFLAGS) -o $@ $^

$(@obj): $(O)/%.o : $(S)/%.cpp | $(O)/
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(O)/:
	@mkdir -p $@

run: $(O)/$(exe)
	./$<

clean:
	rm -rf -- '$(O)'
