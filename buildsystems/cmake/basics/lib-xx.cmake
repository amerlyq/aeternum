#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" "$@" ./main
cmake -E chdir "$t" "$@" ./usage
exit
]]
#%SUMMARY: basic linkable executable (reverse of executable library)
#%USAGE: $ ./$0
#%IDEA: link executables to each other
#%ALT:REF: https://polentino911.wordpress.com/2013/08/08/make-your-own-executable-shared-library-on-linux/
#%
cmake_minimum_required(VERSION 3.14) # CMP0083 NEW
project(main CXX)

file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "
#include <stdio.h>
void hello(char *tag) {
    printf(\"%s: Hello!\\n\", tag);
}
int main(int argc, char *argv[]) {
    hello(argv[0]);
    return 0;
}")

file(WRITE ${PROJECT_BINARY_DIR}/usage.cpp "
#include <stdio.h>
extern void hello(char*);
int main(int argc, char *argv[]) {
    hello(argv[0]);
    return 0;
}")

include(CheckPIESupported)
check_pie_supported()

# HACK: use executable as shared-lib
add_executable(${PROJECT_NAME} main.cpp)
set_target_properties(${PROJECT_NAME} PROPERTIES
  POSITION_INDEPENDENT_CODE TRUE ENABLE_EXPORTS TRUE)

## ALT: modify resulting RPATH
## BUG: substitution "$ORIGIN" done by "ld" -- therefore you must re-link exe on installation, not simply replace RPATH
# set_target_properties(foo PROPERTIES
#   BUILD_WITH_INSTALL_RPATH TRUE
#   INSTALL_RPATH_USE_LINK_PATH TRUE
#   INSTALL_RPATH "\$ORIGIN/../lib:${INSTALL_RPATH}")

# NEED:(GNU_binutils>=2.18): exact name linking "-l:mylib.so"
add_executable(usage usage.cpp)
target_link_directories(usage PRIVATE $<TARGET_FILE_DIR:usage>)
target_link_libraries(usage PRIVATE :${PROJECT_NAME})
# target_link_libraries(usage PRIVATE $<TARGET_FILE:${PROJECT_NAME}>)
# set_target_properties(usage PROPERTIES LINK_FLAGS "-Wl,-rpath,'$ORIGIN'")
