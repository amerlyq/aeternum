#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -DCMAKE_CXX_FLAGS="-Werror" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" "$@" ./main
exit
]]
#%SUMMARY: generate headers with substituted variables to be embedded into binary
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(main CXX)

file(WRITE ${PROJECT_BINARY_DIR}/version.h.in "#define PJ_VERSION @PJ_VERSION@\n")
file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "#include \"version.h\"\nint main(){ return PJ_VERSION; }\n")

set(PJ_VERSION 42)

# FAIL: configure_file() runs immediately on CMake/configure step
#   -- impossible to chain after add_custom_command() for ${helptmpl}
configure_file(version.h.in version.h @ONLY)

add_executable(${PROJECT_NAME} main.cpp)
