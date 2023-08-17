cmake_minimum_required(VERSION 3.7)
project(${NAME}_pj)
# FIXED: suppress folders { Continuous Experimental Nightly }
#   REF: https://stackoverflow.com/questions/44949354/hide-automatically-generated-ctest-targets
set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)
include(CTest)

include(BaseTest.cmake)

add_subdirectory(${NAME})
add_subdirectory(TestAll)
