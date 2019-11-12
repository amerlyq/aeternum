#%SUMMARY: separate TestAll component to run combined tests

set(_tgt test_all)

if(TARGET ${_tgt})
  unset(_tgt)
  return()
endif()

# WARN: can break when included in the middle of file
project(${_tgt})

# DEV:CHG: _MODE={ALTOGETHER,COMPONENTS,TESTFILES}
if(BUILD_TESTING_EXE_PER_COMPONENT)
  set(_opts EXCLUDE_FROM_ALL)
else()
  set(_opts)
endif()

file(WRITE ${PROJECT_BINARY_DIR}/dummy.cpp)
list(APPEND _opts ${PROJECT_BINARY_DIR}/dummy.cpp)

## Unified test executable
add_executable(${_tgt} ${_opts})
unset(_opts)

get_property(_tests GLOBAL PROPERTY test_targets)
list(REMOVE_DUPLICATES _tests)
target_link_libraries(${_tgt} PRIVATE -Wl,--no-as-needed ${_tests})

# message(FATAL_ERROR ": ${_tests}")
add_custom_target(check_all
  COMMAND "$(EMUL)" $<TARGET_FILE:${_tgt}> "$(ARGS)"
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  USES_TERMINAL
  VERBATIM
)

unset(_tgt)
