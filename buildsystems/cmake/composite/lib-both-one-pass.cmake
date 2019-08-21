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
#%SUMMARY:(<flat-category>): build both libs at once
#%USAGE: $ ./$0
#%
project(${NAME} C)

file(WRITE ${PROJECT_BINARY_DIR}/src/${NAME}.h "int filter();\n")
file(WRITE ${PROJECT_BINARY_DIR}/src/${NAME}.c "int filter() { return 8; }\n")

# static (w/o -fPIC/-pie)
add_library(${PROJECT_NAME}-a STATIC src/${NAME}.c)
target_sources(${PROJECT_NAME}-a PRIVATE src/${NAME}.h)
target_include_directories(${PROJECT_NAME}-a PUBLIC src)
set_target_properties(${PROJECT_NAME}-a PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
install(TARGETS ${PROJECT_NAME}-a DESTINATION lib)

# shared (with -fPIC/-pie)
add_library(${PROJECT_NAME}-so SHARED src/${NAME}.c)
target_sources(${PROJECT_NAME}-so PRIVATE src/${NAME}.h)
target_include_directories(${PROJECT_NAME}-so PUBLIC src)
set_target_properties(${PROJECT_NAME}-so PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
install(TARGETS ${PROJECT_NAME}-so DESTINATION lib)

# default one
add_library(${PROJECT_NAME} ALIAS ${PROJECT_NAME}-a)
