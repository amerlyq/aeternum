#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" "$@" ./libmain.so
cmake -E chdir "$t" "$@" ./usage
exit
]]
#%SUMMARY: basic executable library aka linkable executable
#%USAGE: $ ./$0
#%REF: https://unix.stackexchange.com/questions/479333/building-shared-library-which-is-executable-and-linkable-using-cmake/479334#479334
#%REF: https://unix.stackexchange.com/questions/223385/why-and-how-are-some-shared-libraries-runnable-as-though-they-are-executables
#%IDEA: gcc -fPIC -pie -o libtest.so test.c -Wl,-E
#%
cmake_minimum_required(VERSION 3.6.3)
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


# HACK: use shared-lib as executable
add_library(${PROJECT_NAME} SHARED main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)

### Position Independent Executables
# ATT: don't enable PIE until absolutely necessary (security requirements from customer)
#   * fPIE does not provide security on 32bit at all (SEE: exploit return-to-libc)
#   * PIC is harder to debug -- don't take a grudge out on triage developers

# NOTE: new GCC>=6 enables PIE by default (https://gitlab.kitware.com/cmake/cmake/issues/16561)
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-pie" SUPPORTS_CXXFLAG_pie)
if(SUPPORTS_CXXFLAG_pie)
  # INFO: unnecessary for latest cmake
  #   REF: https://gitlab.kitware.com/cmake/cmake/merge_requests/2465
  # OR: project-wide
  # set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pie")
  target_compile_options(${PROJECT_NAME} PUBLIC "-pie")
  # HACK: export symbol table -- so it can be linked
  # ALSO:ALT:(main): -Wl,--entry=__NAME_main
  target_link_libraries(${PROJECT_NAME} "-pie -Wl,-E")
endif()


add_executable(usage usage.cpp)
target_link_libraries(usage main)
