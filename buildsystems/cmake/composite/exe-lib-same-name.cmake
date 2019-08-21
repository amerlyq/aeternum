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
#%SUMMARY: create library and executable with the same name
#%USAGE: $ ./$0
#%CONTRACT: each .cpp must reimplement main(), args processing, textual help, and signal handlers
#%  ALT: link each exe to the same boilerplate .cpp file
#%
project(${NAME} CXX)

file(WRITE ${PROJECT_BINARY_DIR}/src/${NAME}.hpp "
int filter();
")

file(WRITE ${PROJECT_BINARY_DIR}/src/${NAME}.cpp "
#include \"${NAME}.hpp\"
int filter() { return 23; }
")

file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "
#include <${NAME}.hpp>
int main(){ return filter(); }
")

add_library(${PROJECT_NAME} src/${NAME}.cpp)
target_sources(${PROJECT_NAME} PRIVATE src/${NAME}.hpp)
target_include_directories(${PROJECT_NAME} PUBLIC src)
install(TARGETS ${PROJECT_NAME} DESTINATION lib)

add_executable(${PROJECT_NAME}-exe main.cpp)
target_sources(${PROJECT_NAME}-exe PRIVATE src/${NAME}.hpp)
target_link_libraries(${PROJECT_NAME}-exe PRIVATE ${PROJECT_NAME})
set_target_properties(${PROJECT_NAME}-exe PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
install(TARGETS ${PROJECT_NAME}-exe DESTINATION bin)
