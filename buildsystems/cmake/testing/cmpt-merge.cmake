#!/bin/sh -reuC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}/${n:=example}"
cmake -E copy_if_different "${d:=${f%/*}/common}/CMakeLists.txt" "$d"/BaseTest.cmake "$t/"
cmake -E copy_if_different "$d/TestAll.cmake" "$t/TestAll/CMakeLists.txt"
cmake -E copy_if_different "$f" "$t/$n/CMakeLists.txt"
cmake -E copy_if_different "$d/${n:=example}"* "$t/$n/"
cmake -S"$t" -B"$t" -DNAME="$n" -Werror=dev
cmake --build "$t" --clean-first --verbose
cmake --build "$t" --target "check_all" "$@"
exit
]]
#%SUMMARY: run combined testapp by "custom target"
#%USAGE: $ ./$0
#%
project(${NAME} CXX)

add_library(${PROJECT_NAME} ${NAME}.cpp)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR})

if(BUILD_TESTING)
add_executable(test_${PROJECT_NAME} ${NAME}_test.cpp)

set_target_properties(test_${PROJECT_NAME} PROPERTIES
  POSITION_INDEPENDENT_CODE TRUE
  ENABLE_EXPORTS TRUE
  LINK_FLAGS "-pie -Wl,-E")

target_link_libraries(test_${PROJECT_NAME} PUBLIC BaseTest ${PROJECT_NAME})
set_property(GLOBAL APPEND PROPERTY test_targets $<TARGET_FILE:test_${PROJECT_NAME}>)

# get_target_property(_incs ${PROJECT_NAME}_test INCLUDE_DIRECTORIES)
# get_target_property(_libs ${PROJECT_NAME}_test LINK_LIBRARIES)
# message(FATAL_ERROR "${_incs} | ${_libs}")
endif()
