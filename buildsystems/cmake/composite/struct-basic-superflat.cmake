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
#%SUMMARY: examplar minimal <superflat> folder structure
#%USAGE: $ ./$0
#%
project(${NAME} C)

file(WRITE ${PROJECT_BINARY_DIR}/${NAME}.h "int filter();\n")
file(WRITE ${PROJECT_BINARY_DIR}/${NAME}.c "int filter() { return 8; }\n")

add_library(${PROJECT_NAME}
  ${NAME}.c
)

target_sources(${PROJECT_NAME} PRIVATE
  ${NAME}.h
)

target_include_directories(${PROJECT_NAME}
  PUBLIC
    ${PROJECT_BINARY_DIR}
)

target_link_libraries(${PROJECT_NAME}
  PUBLIC
    # Boost::boost
  PRIVATE
    # Threads::Threads
)

install(TARGETS ${PROJECT_NAME} DESTINATION lib)
