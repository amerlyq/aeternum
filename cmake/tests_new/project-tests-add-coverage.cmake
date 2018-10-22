#%SUMMARY: create new (virtual) objects library with "--coverage" enabled
#%  REQUIRED:(input):
#%    * target "${PROJECT_NAME}"
#%    * target "${PROJECT_NAME}_test"
#%  PRODUCED:(output):
#%    * target "${PROJECT_NAME}_cov"
#%

# NOTE: all *.cpp with corresponding tests will be included in coverage report
# OR: declare special new property to contain reduced source list for coverity
#   => BAD: must be set in each CMakeLists.txt explicitly BET: stick to default properties

if(NOT TARGET ${PROJECT_NAME})
  message(FATAL_ERROR "Variable 'PROJECT_NAME=${PROJECT_NAME}' must be an existing target")
endif()

get_target_property(_srcs ${PROJECT_NAME} SOURCES)
get_target_property(_incs ${PROJECT_NAME} INCLUDE_DIRECTORIES)
get_target_property(_libs ${PROJECT_NAME} LINK_LIBRARIES)

### Create full-fledged object lib
## REF: how to use object libraries (i.e. reasoning why PRIVATE/PUBLIC/INTERFACE)
#   https://cmake.org/pipermail/cmake-developers/2015-February/024555.html
#   https://cmake.org/pipermail/cmake-developers/2015-February/024559.html
add_library(${PROJECT_NAME}_cov OBJECT ${_srcs})
target_sources(${PROJECT_NAME}_cov INTERFACE $<TARGET_OBJECTS:${PROJECT_NAME}_cov>)
target_include_directories(${PROJECT_NAME}_cov PUBLIC ${_incs})
target_link_libraries(${PROJECT_NAME}_cov PUBLIC ${_libs} --coverage)
# BAD? can't disable coverage for whole project at once
target_compile_options(${PROJECT_NAME}_cov PRIVATE --coverage)


if(NOT TARGET ${PROJECT_NAME}_test)
  message(FATAL_ERROR "Target '${PROJECT_NAME}_test' must exist")
endif()

### Link object lib with coverage to test object lib
target_link_libraries(${PROJECT_NAME}_test PUBLIC ${PROJECT_NAME}_cov)

### Finalize tests (augment rest of functionality)
include(project-tests-add)
