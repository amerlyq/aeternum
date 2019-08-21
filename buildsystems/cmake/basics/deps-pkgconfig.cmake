#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -DCMAKE_CXX_FLAGS="-Werror" -Werror=dev
cmake --build "$t" --clean-first "$@"
cmake -E chdir "$t" readelf -Wa ./libmain.so
exit
]]
#%SUMMARY: basic shared library project
#%USAGE: $ ./$0
#%WARN:NEED:(cmake>=3.6.3): for IMPORTED_TARGET e.g. "PkgConfig::ICU", and find_package(Boost REQUIRED)
#%
cmake_minimum_required(VERSION 3.6.3)
project(main CXX)

file(WRITE ${PROJECT_BINARY_DIR}/main.hpp "
#include <sqlite3.h>
int query();
")
file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "
#include \"main.hpp\"
int query() {
  sqlite3* db = nullptr;
  sqlite3_open_v2(\":memory:\", &db, SQLITE_OPEN_READWRITE, nullptr);
  int rc = sqlite3_exec(db, \"SELECT icu_load_collation(%Q, %Q)\", 0, 0, 0);
  sqlite3_close(db);
  return rc;
}")


set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON)

find_package(PkgConfig MODULE REQUIRED)
pkg_check_modules(ICU REQUIRED IMPORTED_TARGET icu-io>=63.1 icu-i18n>=63.1)
pkg_check_modules(sqlite3 REQUIRED IMPORTED_TARGET "sqlite3 >= 3.8.7")

add_library(${PROJECT_NAME} SHARED main.cpp)

target_link_libraries(${PROJECT_NAME}
  PUBLIC
    PkgConfig::sqlite3
  PRIVATE
    PkgConfig::ICU
)
