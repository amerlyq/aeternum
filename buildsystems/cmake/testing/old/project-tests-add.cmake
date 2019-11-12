if(NOT TARGET ${PROJECT_NAME})
  message(FATAL_ERROR "Variable 'PROJECT_NAME=${PROJECT_NAME}' must be an existing target")
endif()
if(NOT TARGET ${PROJECT_NAME}_test)
  message(FATAL_ERROR "Target '${PROJECT_NAME}_test' must exist")
endif()

# HACK:TEMP:BAD:(incomplete): allow searching pre-built GTest incs/libs in custom host path
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
# set(GTEST_ROOT ${CMAKE_SOURCE_DIR}/../google_test/prebuilt-prefix)

# NEED:(cmake<=3.7):
set(THREADS_PTHREAD_ARG "2" CACHE STRING "" FORCE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

find_package(GTest REQUIRED)
find_package(GMock REQUIRED)


## HACK: use "*_ifc" to resolve linking here ALSO: gather all "*_test" for later "testrunner"
add_library(${PROJECT_NAME}_ifc INTERFACE)
target_sources(${PROJECT_NAME}_ifc INTERFACE
  $<TARGET_OBJECTS:${PROJECT_NAME}_test>
  $<TARGET_PROPERTY:${PROJECT_NAME}_test,INTERFACE_SOURCES>
)

get_target_property(_libs ${PROJECT_NAME}_test LINK_LIBRARIES)
target_link_libraries(${PROJECT_NAME}_ifc
  INTERFACE
    ${PROJECT_NAME}
    ${_libs}
    ${GMOCK_BOTH_LIBRARIES}
    Threads::Threads
)

set_property(GLOBAL APPEND PROPERTY test_targets ${PROJECT_NAME}_ifc)


## Ignore the warnings caused by GoogleTest
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_compile_options(${PROJECT_NAME}_test PRIVATE
    -Wno-global-constructors
    -Wno-zero-as-null-pointer-constant
  )
endif()


### Augment test object library
get_target_property(_incs ${PROJECT_NAME} INCLUDE_DIRECTORIES)
target_include_directories(${PROJECT_NAME}_test
  PRIVATE
    ${_incs}
  SYSTEM PRIVATE
    ${GTEST_INCLUDE_DIRS}
    ${GMOCK_INCLUDE_DIRS}
)

get_target_property(_libs ${PROJECT_NAME} LINK_LIBRARIES)
# HACK:(dirty): workaround old cmake limitation of inheriting "*.o" by other object libs
list(FILTER _libs EXCLUDE REGEX "^rc::")
set_property(TARGET ${PROJECT_NAME}_test APPEND PROPERTY LINK_LIBRARIES ${_libs})

include(project-tests-add-exe)
