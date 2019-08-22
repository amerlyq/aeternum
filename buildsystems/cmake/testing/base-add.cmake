#!/bin/sh -reuC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -E copy_if_different "${d:=${f%/*}/common}/BaseTest.cmake" "$t/BaseTest/CMakeLists.txt"
cmake -E copy_if_different "$d/${n:=example}"* "$t"
cmake -S"$t" -B"$t" -DNAME="$n" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" ./"test_$n" "$@"
exit
]]
#%SUMMARY: integrating GTest -- by find_package()
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(${NAME} CXX)
include(CTest)

add_library(${PROJECT_NAME} ${NAME}.cpp)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR})

if(BUILD_TESTING)
add_subdirectory(BaseTest)
add_executable(test_${PROJECT_NAME} ${NAME}_test.cpp)
target_link_libraries(test_${PROJECT_NAME} BaseTest ${PROJECT_NAME})
endif()
