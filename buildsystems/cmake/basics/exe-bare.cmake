#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" "$@" ./main
exit
]]
#%SUMMARY: basic executable project
#%USAGE: $ ./$0 [readelf -Wa]
#%
cmake_minimum_required(VERSION 3.6.3)
project(main CXX)

file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "int main(){ return 42; }\n")

add_executable(${PROJECT_NAME} main.cpp)
