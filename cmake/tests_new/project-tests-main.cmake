#%SUMMARY: add unit tests targets
#%  REQUIRED:(input):
#%    * target "${PROJECT_NAME}"
#%  PRODUCED:(output):
#%    * augmented "${PROJECT_NAME}"
#%
#%USAGE:
#%    project(testrunner)
#%    add_executable(${PROJECT_NAME})
#%    include(project-tests-main)
#%
get_property(_tests GLOBAL PROPERTY test_targets)
list(REMOVE_DUPLICATES _tests)
target_link_libraries(${PROJECT_NAME} PRIVATE ${_tests})

# ALT:FAIL: find all targets matching '*_test' and link them
#   get_cmake_property(_tests TARGETS)
#   list(FILTER _tests INCLUDE REGEX "_test$")
