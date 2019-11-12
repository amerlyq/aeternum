#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -DCMAKE_CXX_FLAGS="-Werror" -Werror=dev
cmake --build "$t" --clean-first "$@"
cmake -E chdir "${t%/*}" tree -aACL 1 "${f##*/}"
exit
]]
#%SUMMARY: generate source files from yacc/bison templates
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(main CXX)

file(WRITE ${PROJECT_BINARY_DIR}/main.cpp.in "int main(){ return 88; }\n")

add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/main.cpp
  COMMAND sed "s/88/99/" ${PROJECT_BINARY_DIR}/main.cpp.in > ${PROJECT_BINARY_DIR}/main.cpp
)

add_executable(${PROJECT_NAME} main.cpp)
