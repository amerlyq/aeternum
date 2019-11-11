#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -DCMAKE_CXX_FLAGS="-Werror" -Werror=dev
cmake --build "$t" --clean-first "$@"
cmake -E chdir "$t" readelf -Wa ./main
exit
]]
#%SUMMARY: hide all symbols from exe to reduce startup time (spent for runtime linking)
#%USAGE: $ ./$0
#%
cmake_minimum_required(VERSION 3.6.3)
project(main CXX)

if(POLICY CMP0065)
  ## NOTE: remove "-rdynamic" from target flags -- prevent enforced export
  cmake_policy(SET CMP0065 NEW)
else()
  ## ALT:(workaround): globally suppress "-rdynamic" effect on linker
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-export-dynamic")
  ## OR:(equivalent): completely clear default flags containing "-rdynamic"
  # set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)
  # set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS)
endif()

## REQUIRE: don't export symbols from executables by default
## ATT: if truly required, enable syms export per executable
#   set_target_properties(MyExecutable PROPERTIES ENABLE_EXPORTS ON)
set(CMAKE_ENABLE_EXPORTS OFF)

## ALSO: set global defaults for targets with "ENABLE_EXPORTS ON"
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

if(POLICY CMP0063)
  ## NOTE: Hide symbols also from static *.a and object *.o libs
  cmake_policy(SET CMP0063 NEW)
else()
  ## ALT(workaround): globally hide all symbols indiscriminately
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fvisibility=hidden")
endif()

## NOTE: don't export all static libs *.a symbols automatically
set_directory_properties(PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN ON
  LINK_FLAGS "-Wl,--exclude-libs,ALL"
)


file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "
int query() { int x = 1; return reinterpret_cast<long>(&x); }
int main() { auto p = &query; return p(); }
")

add_executable(${PROJECT_NAME} main.cpp)
