#%SUMMARY: add unit tests targets
#%  REQUIRED:(input):
#%    * target "${PROJECT_NAME}_test"
#%  PRODUCED:(output):
#%    * augmented "${PROJECT_NAME}_test"
#%    * optional "test_${PROJECT_NAME}"
#%
#%USAGE:
#%  BOILERPLATE
#%    if(BUILD_TESTING)
#%    add_library(${PROJECT_NAME}_test OBJECT
#%      test/SomeTest.cpp
#%      test/some_test.cpp
#%    )
#%    include(project-add-tests-coverage)
#%    # include(project-add-tests)  # OR:(w/o coverage)
#%    endif()
#%
#%  STANDALONE
#%    if(BUILD_TESTING)
#%    add_library(${PROJECT_NAME}_test OBJECT
#%      test/SomeTest.cpp
#%      test/some_test.cpp
#%    )
#%    target_link_libraries(${PROJECT_NAME}_test PRIVATE ${PROJECT_NAME} ...)
#%    set_property(GLOBAL APPEND PROPERTY test_targets ${PROJECT_NAME}_test)
#%    endif()
#%
if(NOT TARGET ${PROJECT_NAME}_test)
  message(FATAL_ERROR "Target '${PROJECT_NAME}_test' must exist")
endif()

## Ignore the warnings caused by GoogleTest
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_compile_options(${PROJECT_NAME}_test PRIVATE
    -Wno-global-constructors
    -Wno-zero-as-null-pointer-constant
  )
endif()


# HACK:BAD:(incomplete): allow searching pre-built GTest incs/libs in custom host path
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
# set(GTEST_ROOT ${CMAKE_SOURCE_DIR}/../google_test/prebuilt-prefix)

find_package(GTest REQUIRED)
find_package(GMock REQUIRED)

target_include_directories(${PROJECT_NAME}_test
  SYSTEM PRIVATE
    ${GTEST_INCLUDE_DIRS}
    ${GMOCK_INCLUDE_DIRS}
)

# HACK:BAD:(cmake<=3.7): does not support target_link_libraries(<OBJ_LIB>)
# NOTE: libgmock contains all you need: gtest-all.cc.o gmock-all.cc.o gmock_main.cc.o
target_link_libraries(${PROJECT_NAME}_test
  PUBLIC
    ${GMOCK_BOTH_LIBRARIES}
    pthread
)

## Gather all "*_test" targets for single "testrunner" exe
set_property(GLOBAL APPEND PROPERTY test_targets ${PROJECT_NAME}_test)

## DEBUG:
# get_target_property(_incs ${PROJECT_NAME}_test INCLUDE_DIRECTORIES)
# get_target_property(_libs ${PROJECT_NAME}_test LINK_LIBRARIES)
# message(FATAL_ERROR "${_incs} | ${_libs}")

if(BUILD_TESTING_EXE_PER_COMPONENT)
  include(project-tests-add-exe)
endif()
