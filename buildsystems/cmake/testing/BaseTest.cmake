#%SUMMARY: common BaseTest to link into your testapps
#%DEPS: |community/gtest| and |community/gmock|

set(_tgt BaseTest)

if(TARGET ${_tgt})
  unset(_tgt)
  return()
endif()


# HACK:TEMP:BAD:(incomplete): allow searching pre-built GTest incs/libs in custom host path
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
# set(GTEST_ROOT ${CMAKE_SOURCE_DIR}/../google_test/prebuilt-prefix)


# REF: https://gitlab.kitware.com/cmake/cmake/issues/16920
if(CMAKE_VERSION VERSION_LESS_EQUAL "3.9.0")
  set(THREADS_PTHREAD_ARG "2" CACHE STRING "" FORCE)
endif()
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

find_package(PkgConfig MODULE REQUIRED)
pkg_check_modules(GTest REQUIRED IMPORTED_TARGET gtest)  #  gtest_main
pkg_check_modules(GMock REQUIRED IMPORTED_TARGET gmock gmock_main)

## ALT:REQ: custom FindGMock.cmake
# find_package(GTest REQUIRED)
# find_package(GMock REQUIRED)
# target_include_directories(${_tgt} SYSTEM INTERFACE ${GTEST_INCLUDE_DIRS} ${GMOCK_INCLUDE_DIRS})
# target_link_libraries(${_tgt} INTERFACE ${GMOCK_BOTH_LIBRARIES} Threads::Threads)

add_library(${_tgt} INTERFACE IMPORTED GLOBAL)

target_link_libraries(${_tgt}
  INTERFACE
    PkgConfig::GMock
    PkgConfig::GTest
    Threads::Threads
)

unset(_tgt)
