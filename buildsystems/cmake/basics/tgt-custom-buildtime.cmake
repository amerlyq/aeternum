#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -DCMAKE_CXX_FLAGS="-Werror" -Werror=dev
cmake --build "$t" --clean-first "$@"
cmake --build "$t" --target testdata
cmake -E chdir "${t%/*}" tree -L 1 "${f##*/}"
exit
]]
#%SUMMARY: run custom target to prepare testdata in build time
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(main CXX)

file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "int main(){ return 88; }\n")

add_executable(${PROJECT_NAME} main.cpp)


add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/testdata.db
  COMMAND touch ${CMAKE_BINARY_DIR}/testdata.db
)
add_custom_target(testdata
  COMMAND echo "*** generate testdata"
  DEPENDS ${CMAKE_BINARY_DIR}/testdata.db
)
add_dependencies(${PROJECT_NAME} testdata)
