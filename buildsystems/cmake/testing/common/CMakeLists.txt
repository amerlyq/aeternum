cmake_minimum_required(VERSION 3.7)
project(${NAME}_pj)
include(CTest)

include(BaseTest.cmake)

add_subdirectory(${NAME})
add_subdirectory(TestAll)
