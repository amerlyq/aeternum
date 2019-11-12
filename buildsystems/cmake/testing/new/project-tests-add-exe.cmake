#%SUMMARY: per-component gtest executable
#%WARN: running requires per-component ./test_data/
#%  REQUIRED:(input):
#%    * object library "${PROJECT_NAME}_test"
#%    * option(BUILD_TESTING_EXE_PER_COMPONENT "Build individual test executables for each component" OFF)
#%  PRODUCED:(output):
#%    * executable binary "test_${PROJECT_NAME}"
#%

## USAGE:PERF: build on demand component-specific tests e.g $ make test X=SomeComponent
# [_] ALSO:DEV:(even faster relinking and gdb reload): BUILD_TESTING_EXE_PER_TESTFILE
if(BUILD_TESTING_EXE_PER_COMPONENT)
  set(_opts)
else()
  set(_opts EXCLUDE_FROM_ALL)
endif()

## NOTE: component-specific test executable
add_executable(test_${PROJECT_NAME} ${_opts})
target_link_libraries(test_${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_test)
unset(_opts)

if(BUILD_TESTING_STRIP)
  target_link_libraries(test_${PROJECT_NAME} PRIVATE -Wl,--strip-all)
endif()

# NOTE: when enabled -- global "testrunner" removed from CTest (prevent running same tests)
add_test(test_${PROJECT_NAME} test_${PROJECT_NAME})

# NOTE: special global target to run only component-specific tests
add_custom_target(check_${PROJECT_NAME}
  COMMAND "$(EMUL)" $<TARGET_FILE:test_${PROJECT_NAME}> "$(ARGS)"
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  USES_TERMINAL
  VERBATIM
)
