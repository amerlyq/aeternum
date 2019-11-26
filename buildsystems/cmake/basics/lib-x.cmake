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
#%IDEA:(export symbol table):ALSO:ALT:(main): -Wl,--entry=__NAME_main
#%  $ echo 'int fun(){return 42;}' | gcc -fPIC -pie -Wl,-E -Wl,--defsym=main=fun -o libxxx.so -xc -
#%  $ echo 'int fun(); int main(){return fun();}' | gcc -L. -Wl,--rpath=. -o usexxx -xc - -lxxx
#%SEE: analogs from other languages :: https://rosettacode.org/wiki/Executable_library
#%  $ echo 'static const char interp[] __attribute__((section(".interp"))) = "/lib64/ld-linux-x86-64.so.2"; int fun(){return 42;}' | gcc -fPIC -shared -o libxxx.so -xc - -lc -Wl,-e,fun
#%FAIL: don't work anymore due to problems in PIE loading by rtdl ::
#%  * "Refuse to dlopen PIE objects [BZ #24323]" :: https://patchwork.ozlabs.org/patch/1055380/
#%  * http://sourceware-org.1504.n7.nabble.com/Bug-dynamic-link-24323-New-dlopen-should-not-be-able-open-PIE-objects-td562159.html#a562160
#%  * ALG:(ctors problem): https://sourceware.org/bugzilla/show_bug.cgi?id=11754#c15
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
set_target_properties(${PROJECT_NAME} PROPERTIES
  POSITION_INDEPENDENT_CODE TRUE)

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
  # OR:(project-wide): set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pie")
  target_compile_options(${PROJECT_NAME} PUBLIC "-pie")
  target_link_libraries(${PROJECT_NAME} "-pie -Wl,-E")
endif()

# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath='$ORIGIN'")

add_executable(usage usage.cpp)
target_link_libraries(usage ${PROJECT_NAME})
