#!/usr/bin/env -S make -rRBf
#%SUMMARY: evolution from zero (implicit recipes, ATT: exe-per-cpp)
#%USAGE: $ make _build/main
.DEFAULT_GOAL = run-main
O := _build
S := src

CXX := g++
CXXFLAGS += -g -Wall -Werror
CXXFLAGS += -I$(S)

#%NOTE: when multiple dirs, use:
# CXXFLAGS += $(d_inc:%=-I%)
# CXXFLAGS += $(addprefix -I,$(d_inc))

@src := $(wildcard $(S)/*.cpp)
@exe := $(@src:$(S)/%.cpp=$(O)/%)

# ALT:(GPATH): rebuild out-of-date where found (instead of in cwd)
# REF: https://www.gnu.org/software/make/manual/make.html#Search-Algorithm
vpath %.cpp $(S)
vpath %.hpp $(S)

all: $(@exe)

%: %.o
	$(CXX) $(LDFLAGS) -o $@ $^

$(O)/%.o: %.cpp | $(O)/
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(O)/:
	@mkdir -p $@

run-%: $(O)/%
	./$<

clean:
	rm -rf -- '$(O)'
