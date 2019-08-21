#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
cmake -E copy_if_different "$f" "$t/CMakeLists.txt"
cmake -S"$t" -B"$t" -DSRCDIR:PATH="${f%/*}" -Werror=dev
cmake --build "$t" --clean-first
cmake -E chdir "$t" "$@" ./main
exit
]]
#%SUMMARY: demo how to use embedded resources (and "writev" syscall)
#%USAGE: $ ./$0
#%DOCS: ./embedded-resources.nou
#%REF: http://man7.org/linux/man-pages/man2/readv.2.html
#%
cmake_minimum_required(VERSION 3.6.3)
project(main C)

file(WRITE ${PROJECT_BINARY_DIR}/main.c "
#include <embedded_resources_nou.i>
#include <example.i>
#include <sys/uio.h>
int main(){
  struct iovec iov[5];
  iov[0].iov_base = \"\\n[Test] writev(...):\\n\";
  iov[0].iov_len = 21;
  iov[1].iov_base = (void*)embedded_resources_nou_start;
  iov[1].iov_len = 100;
  iov[2].iov_base = \"\\n\\n\";
  iov[2].iov_len = 1;
  iov[3].iov_base = (void*)example_start;
  iov[3].iov_len = 200;
  iov[4].iov_base = \"\\n\";
  iov[4].iov_len = 1;

  int iovcnt = sizeof(iov) / sizeof(struct iovec);
  ssize_t nbyte = writev(1, iov, iovcnt);
  return nbyte;
}
")

set(CMAKE_MODULE_PATH ${SRCDIR})

include(EmbeddedResources)
make_resource(example ${SRCDIR}/usage-add-resource.cmake)
make_resource_from_each(
  LOCAL
    ${SRCDIR}/embedded-resources.nou
)

add_executable(${PROJECT_NAME} main.c)

target_link_libraries(${PROJECT_NAME}
  PRIVATE
    rc::embedded_resources_nou
    rc::example
)
