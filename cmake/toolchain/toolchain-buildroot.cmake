# REQ: params
#   -DHOST_PREFIX=/path/to/buildroot/output/host -DCMAKE_SYSROOT=/path/to/sysroot
#
# WARN: can't use ./buildroot/output/host/usr/share/buildroot/toolchainfile.cmake
# * Some vars can be specified only inside toolchain files e.g. CMAKE_SYSROOT
# * Broken buildsystem uses ./buildroot/rootfs/ instead of ./host/usr/arm-buildroot-linux-gnueabihf/sysroot
#   => mess of libs -- what, where and in which order links to another
# * BAD: using CMAKE_FIND_ROOT_PATH="$rootfs"
#   !! overriden by toolchain -- no way to append
# * No easy way to override CMAKE_FIND_ROOT_PATH specified in toolchain
#   => required for correct find_library(), etc -- otherwise workarounds must be placed in each find_*() call
# * BAD: using CMAKE_STAGING_PREFIX=./buildroot/rootfs
#   => conflicts with already set sysroot "Cannot generate a safe runtime search path"
#   !! doesn't search in ./usr/lib by default -- not prepended to each other system path
# * BAD: using CMAKE_PREFIX_PATH="$rootfs/usr:$rootfs"
#   => somewhat prevent complaints "Cannot generate a safe runtime search path"
#   !! prefixed by CMAKE_FIND_ROOT_PATH => no sense to use
# * BAD: using CMAKE_INSTALL_PREFIX="$rootfs/usr"
#   => additionally searched here (appended to CMAKE_SYSTEM_PREFIX_PATH)
#   !! prefixed by CMAKE_FIND_ROOT_PATH => no sense to use
# * ALT: using CMAKE_SYSROOT="$rootfs" => overrides sysroot set by CMAKE_FIND_ROOT_PATH
#   WARN:HACK:(inappropriate usage): according to docs CMAKE_SYSROOT must be set only inside toolchain file
#   REF: https://cmake.org/cmake/help/v3.7/variable/CMAKE_SYSROOT.html#variable:CMAKE_SYSROOT
# * ATT: toolchain is sourced multiple times -- NEED cache passed control vars for toolchain itself inside env vars
#   https://stackoverflow.com/questions/28613394/check-cmake-cache-variable-in-toolchain-file


set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

### Paths
# set(CMAKE_SYSROOT $ENV{CMAKE_SYSROOT})
# set(CMAKE_FIND_ROOT_PATH "${HOST_PREFIX}/usr/arm-buildroot-linux-gnueabihf/sysroot")
# set(CMAKE_STAGING_PREFIX /path/to/staging)


### Compilers
set(CMAKE_C_COMPILER "${HOST_PREFIX}/usr/bin/arm-linux-gnueabihf-gcc")
set(CMAKE_CXX_COMPILER "${HOST_PREFIX}/usr/bin/arm-linux-gnueabihf-g++")
set(CMAKE_C_FLAGS "-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -pipe -Os ${CMAKE_C_FLAGS}" CACHE STRING "Buildroot CFLAGS")
set(CMAKE_CXX_FLAGS "-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -pipe -Os ${CMAKE_CXX_FLAGS}" CACHE STRING "Buildroot CXXFLAGS")
# set(CMAKE_EXE_LINKER_FLAGS " ${CMAKE_EXE_LINKER_FLAGS}" CACHE STRING "Buildroot LDFLAGS")


### Configure find_*(), pkg_check_*()
# set(ENV{PKG_CONFIG_SYSROOT_DIR} "${HOST_PREFIX}/usr/arm-buildroot-linux-gnueabihf/sysroot")
# ALT:(for cmake<3.1): export PKG_CONFIG_PATH="$dst/lib/pkgconfig:${PKG_CONFIG_PATH-}"
#   export LDFLAGS="-L'$prf_install/lib'" && ... && unset LDFLAGS
#     <= WARN: "$prf_install" path must not contain single-quotes!
set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_PROGRAM_PATH "${HOST_PREFIX}/usr/bin")
set(CMAKE_INSTALL_SO_NO_EXE 0)


# NOTE: enable buildroot's ccache by default (if found)
# WARN: by default buildroot's ccache is disabled -- only /usr/bin/ccache found
if(NOT DEFINED USE_CCACHE OR NOT USE_CCACHE)
  find_program(CCACHE ccache HINTS "${HOST_PREFIX}/usr/bin")
  if(CCACHE)
    message(STATUS "ccache program has been found and will be used for the build.")
    message(STATUS "  To disable ccache, add -DUSE_CCACHE=OFF on the cmake command line.")
    set(CMAKE_ASM_COMPILER "${HOST_PREFIX}/usr/bin/arm-linux-gnueabihf-gcc")
    set(CMAKE_C_COMPILER "${HOST_PREFIX}/usr/bin/ccache")
    set(CMAKE_CXX_COMPILER "${HOST_PREFIX}/usr/bin/ccache")
    set(CMAKE_C_COMPILER_ARG1 "${HOST_PREFIX}/usr/bin/arm-linux-gnueabihf-gcc")
    set(CMAKE_CXX_COMPILER_ARG1 "${HOST_PREFIX}/usr/bin/arm-linux-gnueabihf-g++")
  endif()
endif()
