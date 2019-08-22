#!/usr/bin/make -srRf
#[[ -*- mode: cmake; -*-
.DEFAULT_GOAL = run
f := $(lastword $(MAKEFILE_LIST))
t := $(or $(TMPDIR),/tmp)/$(abspath $f)
n := main
$t/CMakeLists.txt: $f ; mkdir -p '$(@D)' && cp -f '$<' '$@'
$t/CMakeCache.txt: $t/CMakeLists.txt ; cmake -S'$(<D)' -B'$(@D)' -DNAME='$n' -Werror=dev
$t/$n: $t/CMakeCache.txt ; cmake --build '$(@D)' --clean-first && touch '$@'
run: $t/$n ; cmake -E chdir '$t' $(RUN) ./$n $(ARGS)
define cmake
]]
#%SUMMARY: makefile shebang with unchanged CWD
#%USAGE: $ [RUN="gdb --args"] [ARGS="..."] ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(${NAME} CXX)

file(WRITE ${PROJECT_BINARY_DIR}/${NAME}.cpp "int main(){ return 71; }\n")

add_executable(${PROJECT_NAME} ${NAME}.cpp)
#[[ epilog
endef #]]
