#%SUMMARY: per-component gtest executable
#%WARN: running requires per-component ./test_data/
#%  REQUIRED:(input):
#%    * object library "${PROJECT_NAME}_test"
#%    * option(BUILD_TESTING_EXE_PER_COMPONENT "Build individual test executables for each component" OFF)
#%  PRODUCED:(output):
#%    * executable binary "test_${PROJECT_NAME}"
#%
add_executable(test_${PROJECT_NAME})
target_link_libraries(test_${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_test)

if(BUILD_TESTING_STRIP)
  target_link_libraries(test_${PROJECT_NAME} PRIVATE -Wl,--strip-all)
endif()

# NOTE: when enabled -- global "testrunner" removed from CTest (prevent running same tests)
add_test(test_${PROJECT_NAME} test_${PROJECT_NAME})
