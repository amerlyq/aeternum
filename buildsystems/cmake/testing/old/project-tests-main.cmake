#%BET:FIXME: introduce "install" step with "test" config before running
#%   + stripping will be done by CMake flags
#%   + test data will be available in the expected place
#%   + no cluttering by build files
#%
#%SUMMARY: add unit tests targets
#%  REQUIRED:(input):
#%    * target "${PROJECT_NAME}"
#%  PRODUCED:(output):
#%    * augmented "${PROJECT_NAME}"
#%
#%USAGE:
#%    project(testapp)
#%    add_executable(${PROJECT_NAME})
#%    include(project-tests-main)
#%
#%BET:(test_all):BAD:(testrunner|testapp): emphasize tests are for all separate sub-projects at once
project(test_all)

if(BUILD_TESTING_STRIP)
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--strip-all")
endif()

## USAGE: switch DFL: build single testapp OR: per-component
# NOTE: you can still manually build+run unified tests if needed
#   $ make test X=test_all
# [_] THINK: maybe it's useless feature
if(BUILD_TESTING_EXE_PER_COMPONENT)
  set(_opts EXCLUDE_FROM_ALL)
else()
  set(_opts)
endif()

if(CMAKE_VERSION VERSION_LESS "3.11.0")
  # HACK: add empty source file to overcome limitations of add_executable()
  file(WRITE ${PROJECT_BINARY_DIR}/dummy.cpp)
  list(APPEND _opts ${PROJECT_BINARY_DIR}/dummy.cpp)
endif()

## Unified test executable
add_executable(${PROJECT_NAME} ${_opts})
unset(_opts)

# ALT:OLD: link directly object files
# get_property(_objs GLOBAL PROPERTY test_objects)
# target_sources(${PROJECT_NAME} PRIVATE ${_objs})

# NOTE: populate exe with objects gathered by "project-tests-add.cmake"
get_property(_tests GLOBAL PROPERTY test_targets)
target_link_libraries(${PROJECT_NAME} PRIVATE ${_tests})

## USAGE: run tests DFL: single testapp OR: per-component
#  ALT: run manually $ ctest test_all
if(NOT BUILD_TESTING_EXE_PER_COMPONENT)
  add_test(${PROJECT_NAME} ${PROJECT_NAME})
endif()

# FAIL: passing "$(ARGS)" don't work for Ninja generator
add_custom_target(check_${PROJECT_NAME}
  COMMAND "$(EMUL)" $<TARGET_FILE:${PROJECT_NAME}> "$(ARGS)"
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  USES_TERMINAL
  VERBATIM
)
