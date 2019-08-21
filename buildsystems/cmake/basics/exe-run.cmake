#!/bin/sh -eufC
#[[ -*- mode: cmake; -*-
x=${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}/CMakeLists.txt
if ! cmake -E compare_files "$f" "$x"; then
  cmake -E make_directory "$t"
  cmake -E copy_if_different "$f" "$x"
  cmake -S"$t" -B"$t" -DNAME="${f##*/}" -Werror=dev
  cmake --build "$t" --parallel "$(nproc)" --clean-first
fi
exec "$t/${f##*/}" "$@"
]]
#%SUMMARY: basic self-running cached executable
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(${NAME} CXX)

file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "int main(){ return 37; }\n")

add_executable(${PROJECT_NAME} main.cpp)
