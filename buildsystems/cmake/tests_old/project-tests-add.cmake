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


# HACK:TEMP:BAD:(incomplete): allow searching pre-built GTest incs/libs in custom host path
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
# set(GTEST_ROOT ${CMAKE_SOURCE_DIR}/../google_test/prebuilt-prefix)

find_package(GTest REQUIRED)
find_package(GMock REQUIRED)

### Augment test object library
target_include_directories(${PROJECT_NAME}_test
  SYSTEM PRIVATE
    ${GTEST_INCLUDE_DIRS}
    ${GMOCK_INCLUDE_DIRS}
)

set_property(TARGET ${PROJECT_NAME}_test APPEND PROPERTY
  LINK_LIBRARIES
    ${GMOCK_BOTH_LIBRARIES}
    pthread
)


## Gather all "*_test" into single "testrunner" exe
set_property(GLOBAL APPEND PROPERTY test_objects
  $<TARGET_OBJECTS:${PROJECT_NAME}_test>
  $<TARGET_PROPERTY:${PROJECT_NAME}_test,INTERFACE_SOURCES>
)


# ALSO:DEV:(faster relinking and gdb reload): BUILD_TESTING_EXE_PER_TESTFILE
if(BUILD_TESTING_EXE_PER_COMPONENT)
  include(project-tests-add-exe)
endif()
