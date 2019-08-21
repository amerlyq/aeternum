#!/bin/sh -euf
#[[ -*- mode: cmake; -*-
x=${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}/${n:=myfilter}/CMakeLists.txt
cmake -E make_directory "$t"
cmake -E copy_if_different "$f" "$x"
cat> "$t/CMakeLists.txt" <<'EOT'
  cmake_minimum_required(VERSION 3.7)
  project(${NAME}_pj)
  add_subdirectory(${NAME})
EOT
cmake -S"$t" -B"$t" -DNAME="$n" -Werror=dev
cmake --build "$t" --clean-first
cmake --install "$t" --prefix "$t/_install" --strip
cmake -E chdir "${t%/*}" tree "${f##*/}/_install" "$@"
exit
]]
#%SUMMARY:(<flat-category>): create both libs from the same set of objects
#%USAGE: $ ./$0
#%NICE: avoids compiling twice BAD: -fPIC results in runtime overhead for .a
#%REF: https://stackoverflow.com/questions/2152077/is-it-possible-to-get-cmake-to-build-both-a-static-and-shared-version-of-the-sam
#%
cmake_policy(SET CMP0076 NEW)  # INFO:(cmake>3.13): absolute paths in target_sources()

project(${NAME} C)

file(WRITE ${PROJECT_BINARY_DIR}/src/${NAME}.h "int filter();\n")
file(WRITE ${PROJECT_BINARY_DIR}/src/${NAME}.c "int filter() { return 8; }\n")

# objects (with -fPIC to be able to reuse)
add_library(${PROJECT_NAME}-obj OBJECT src/${NAME}.c)
target_sources(${PROJECT_NAME}-obj PUBLIC src/${NAME}.h)
target_include_directories(${PROJECT_NAME}-obj PUBLIC src)
set_property(TARGET ${PROJECT_NAME}-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

# static (w/o -fPIC/-pie)
add_library(${PROJECT_NAME}-a STATIC $<TARGET_OBJECTS:${PROJECT_NAME}-obj>)
set_target_properties(${PROJECT_NAME}-a PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
install(TARGETS ${PROJECT_NAME}-a DESTINATION lib)

# shared (with -fPIC/-pie)
add_library(${PROJECT_NAME}-so SHARED $<TARGET_OBJECTS:${PROJECT_NAME}-obj>)
set_target_properties(${PROJECT_NAME}-so PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
install(TARGETS ${PROJECT_NAME}-so DESTINATION lib)

# default one
add_library(${PROJECT_NAME} ALIAS ${PROJECT_NAME}-a)
