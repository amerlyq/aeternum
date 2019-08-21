#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -DNAME="${n:=main}" -Werror=dev ${WARN+--warn-uninitialized --warn-unused-vars} ${DEBUG+--debug-output}
cmake ${VERBOSE+--verbose} --build "$t" --parallel "$(nproc)" --clean-first --
cmake --install "$t" --prefix "${i:=$t/_install}" --strip
cmake -E chdir "$i/bin" "$@" ./"$n"
exit
]]
#%SUMMARY: basic executable project
#%USAGE: $ ./$0 [readelf -Wa]
#%
cmake_minimum_required(VERSION 3.6.3)
project(${NAME} CXX)

file(WRITE ${PROJECT_BINARY_DIR}/${NAME}.cpp "int main(){ return 42; }\n")

add_executable(${PROJECT_NAME} ${NAME}.cpp)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
