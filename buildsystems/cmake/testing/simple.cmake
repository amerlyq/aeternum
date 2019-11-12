# Each module boilerplate test code
if(BUILD_TESTING)
get_target_property(_srcs ${PROJECT_NAME} SOURCES)
add_library(${PROJECT_NAME}_test OBJECT ${_srcs}
    test/some_test.cpp
    # OR: test/SomeTest.cpp
)
get_target_property(_incs ${PROJECT_NAME} INCLUDE_DIRECTORIES)
target_include_directories(${PROJECT_NAME}_test PRIVATE ${_incs} test)
# BAD? can't disable coverage for whole project at once
target_link_libraries(${PROJECT_NAME}_test PRIVATE --coverage ${PROJECT_NAME})
target_compile_options(${PROJECT_NAME}_test PRIVATE --coverage)
set_property(GLOBAL APPEND PROPERTY test_objects $<TARGET_OBJECTS:${PROJECT_NAME}_test>)
endif()

# Main testrunner
get_property(_objs GLOBAL PROPERTY test_objects)
add_executable(${PROJECT_NAME} ${_objs})
