#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" "$@" ./main
exit
]]
#%SUMMARY: basic executable project which depends on existing system-wide libraries
#%USAGE: $ ./$0 [readelf -Wa]
#%
cmake_minimum_required(VERSION 3.6.3)
project(main CXX)

file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "
#include <boost/filesystem/operations.hpp>
#include <iostream>
namespace fs = boost::filesystem;
int main(){
  std::cout << fs::current_path().string() << std::endl;
  return 0;
}
")


# USAGE: prefer CMake way instead of directly linking with -lpthread
# NOTE: declare program-wide to affect ext-deps linking
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
# NEED:(cmake<=3.7):
# set(THREADS_PTHREAD_ARG "2" CACHE STRING "" FORCE)
find_package(Threads REQUIRED)


# INFO:(cmake=3.5): default on Ubuntu 16.04
# FIXED:BUG:(Boost::boost target was not found):
#   occurs if first ever "find_package(Boost REQUIRED)"
#   met by CMake don't have any components specified
if(CMAKE_VERSION VERSION_LESS "3.6.0")
  set(_Boost_IMPORTED_TARGETS TRUE)
endif()
find_package(Boost REQUIRED COMPONENTS filesystem)


add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
  PUBLIC
    Boost::filesystem
    # Boost::boost
  PRIVATE
    Threads::Threads
)
