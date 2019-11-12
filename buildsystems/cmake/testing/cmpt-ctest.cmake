#!/bin/sh -eu
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}/${n:=example}"
cmake -E copy_if_different "$f" "$t/$n/CMakeLists.txt"
cmake -E copy_if_different "${d:=${f%/*}/common}/BaseTest.cmake" "$t/"
cmake -E copy_if_different "$d/${n:=example}"* "$t/$n/"
cat> "$t/CMakeLists.txt" <<'EOT'
  cmake_minimum_required(VERSION 3.7)
  project(${NAME}_pj)
  include(CTest)
  include(BaseTest.cmake)
  add_subdirectory(${NAME})
EOT
cmake -S"$t" -B"$t" -DNAME="$n" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" ctest --verbose "$@"
exit
]]
#%SUMMARY: run per-component tests by "ctest"
#%USAGE: $ ./$0
#%
project(${NAME} CXX)

add_library(${PROJECT_NAME} ${NAME}.cpp)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR})

if(BUILD_TESTING)
add_executable(test_${PROJECT_NAME} ${NAME}_test.cpp)
target_link_libraries(test_${PROJECT_NAME} BaseTest ${PROJECT_NAME})
add_test(NAME ${PROJECT_NAME} COMMAND test_${PROJECT_NAME})
endif()
