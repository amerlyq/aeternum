#!/bin/sh -reuC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -E copy_if_different "${d:=${f%/*}/common}/BaseTest"* "$d/${n:=example}"* "$t"
cmake -S"$t" -B"$t" -DNAME="$n" -Werror=dev
cmake --build "$t" --target "check_${X:-$n}${F:+/fast}" -- ${E:+EMUL="$E"} ${@:+ARGS="--gtest_filter='$*'"}
exit
]]
#%SUMMARY: use "special custom target" to call tests
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(${NAME} CXX)
include(CTest)

add_library(${PROJECT_NAME} ${NAME}.cpp)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR})

if(BUILD_TESTING)
include(BaseTest.cmake)
add_executable(test_${PROJECT_NAME} ${NAME}_test.cpp)
target_link_libraries(test_${PROJECT_NAME} BaseTest ${PROJECT_NAME})

add_custom_target(check_${PROJECT_NAME}
  COMMAND "$(EMUL)" $<TARGET_FILE:test_${PROJECT_NAME}> "$(ARGS)"
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  USES_TERMINAL
  VERBATIM
)
endif()
