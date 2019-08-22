#!/bin/sh -reuC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -E copy_if_different "${d:=${f%/*}/common}/BaseTest"* "$d/${n:=example}"* "$t"
cmake -S"$t" -B"$t" -DNAME="$n" -Werror=dev
cmake --build "$t" --clean-first
cmake --install "$t" --component test --prefix "${i:=$t/_install}" --strip
cmake -E chdir "$i/opt" ./"test_$n" "$@"
exit
]]
#%SUMMARY: install and setup env before testing
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(${NAME} CXX)
include(CTest)

add_library(${PROJECT_NAME} ${NAME}.cpp)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR})
install(TARGETS ${PROJECT_NAME} DESTINATION bin)

if(BUILD_TESTING)
include(BaseTest.cmake)
add_executable(test_${PROJECT_NAME} ${NAME}_test.cpp)
target_link_libraries(test_${PROJECT_NAME} BaseTest ${PROJECT_NAME})
install(TARGETS test_${PROJECT_NAME} DESTINATION opt COMPONENT test EXCLUDE_FROM_ALL)
endif()
