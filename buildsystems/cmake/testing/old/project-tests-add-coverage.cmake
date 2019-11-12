## WARN:PERF: don't use coverage on ARM
#   * src dirs / abspaths do not exist there
#   * running is very slow due to trying write in noexistent dirs
#   * can reuse libs instead of rebuilding everything with --coverage (less build time)
if(PLATFORM_ARCHITECTURE STREQUAL "ARM")
  include(project-tests-add)
  return()
endif()

if(NOT TARGET ${PROJECT_NAME})
  message(FATAL_ERROR "Variable 'PROJECT_NAME=${PROJECT_NAME}' must be an existing target")
endif()

get_target_property(_srcs ${PROJECT_NAME} SOURCES)
get_target_property(_incs ${PROJECT_NAME} INCLUDE_DIRECTORIES)
get_target_property(_libs ${PROJECT_NAME} LINK_LIBRARIES)

# HACK:(dirty): workaround old cmake limitation of inheriting "*.o" by other object libs
set(_ress ${_libs})
list(FILTER _ress INCLUDE REGEX "^rc::")
list(FILTER _libs EXCLUDE REGEX "^rc::")
foreach(_res IN LISTS _ress)
  get_target_property(_val ${_res} INTERFACE_INCLUDE_DIRECTORIES)
  list(APPEND _incs ${_val})
endforeach()

### Create new (virtual) objects library with "--coverage" enabled
## REF: how to use object libraries (i.e. reasoning why PRIVATE/PUBLIC/INTERFACE)
#   https://cmake.org/pipermail/cmake-developers/2015-February/024555.html
#   https://cmake.org/pipermail/cmake-developers/2015-February/024559.html
add_library(${PROJECT_NAME}_cov OBJECT ${_srcs})
target_include_directories(${PROJECT_NAME}_cov PRIVATE ${_incs})
target_compile_options(${PROJECT_NAME}_cov PRIVATE --coverage)
set_property(TARGET ${PROJECT_NAME}_cov APPEND PROPERTY LINK_LIBRARIES ${_libs})

### Finalize tests (augment rest of functionality)
include(project-tests-add)

### Populate with alternative objects rebuilt under "--coverage"
target_sources(${PROJECT_NAME}_ifc INTERFACE $<TARGET_OBJECTS:${PROJECT_NAME}_cov>)
target_link_libraries(${PROJECT_NAME}_ifc INTERFACE --coverage)
# HACK:(cmake<=3.7):BAD:(does not support): target_link_libraries(<OBJ_LIB> PUBLIC <OBJ_LIB>)
# set_property(TARGET ${PROJECT_NAME}_ifc APPEND_STRING PROPERTY LINK_FLAGS "--coverage")
