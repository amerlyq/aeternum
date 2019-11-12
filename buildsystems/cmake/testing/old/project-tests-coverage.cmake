#%SUMMARY: enable coverage report for testapp
#%
# BUG:TEMP: lcov coverage is broken in GCC 8.1
#   https://github.com/linux-test-project/lcov/issues/38

include(project-tests-main)
set(coverage_TARGET ${PROJECT_NAME})
include(coverage-report)
