#%WARN: running requires per-component ./test_data/

### Per-component gtest executable
add_executable(test_${PROJECT_NAME}
  $<TARGET_OBJECTS:${PROJECT_NAME}_test>
  $<TARGET_PROPERTY:${PROJECT_NAME}_test,INTERFACE_SOURCES>
)

target_link_libraries(test_${PROJECT_NAME} PRIVATE
  $<TARGET_PROPERTY:${PROJECT_NAME}_test,LINK_FLAGS>
  $<TARGET_PROPERTY:${PROJECT_NAME}_test,LINK_LIBRARIES>
)

if(BUILD_TESTING_STRIP)
  target_link_libraries(test_${PROJECT_NAME} PRIVATE -Wl,--strip-all)
endif()

# NOTE: when enabled -- global "testrunner" removed from CTest (prevent running same tests)
add_test(test_${PROJECT_NAME} test_${PROJECT_NAME})
