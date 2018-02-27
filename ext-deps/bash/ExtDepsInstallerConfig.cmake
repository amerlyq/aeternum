# USAGE: call ./ext-deps script to build deps when necessary on configure step on CMake
set(_pkgname ExtDepsInstaller)


## Search script
find_program(${_pkgname}_EXECUTABLE NAMES "ext-deps"
  PATHS ${CMAKE_SOURCE_DIR}
  PATH_SUFFIXES scripts
  # MAYBE: allow adding ./ext-deps to PATH ?
  NO_DEFAULT_PATH
)


## Process find_package() STD args
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${_pkgname}
  FOUND_VAR ${_pkgname}_FOUND
  REQUIRED_VARS ${_pkgname}_EXECUTABLE)
mark_as_advanced(${_pkgname}_EXECUTABLE)


# NOTE: must be run before
# BAD:NEED: hash additional args together with script
#   * detects when new arguments specified
# BAD! if cached vars file is changed -- deps won't be rebuilt
#   ? MAYBE: add key "-D" to enlist additional timestamp dependencies for packages ?
function(ext_deps_install_now)
  foreach(_pkg ${ARGN})
    execute_process(
      COMMAND "${${_pkgname}_EXECUTABLE}" -i ${_pkg}
      RESULT_VARIABLE _exit_code
      OUTPUT_VARIABLE _stdout
      ERROR_VARIABLE _stderr
    )
    if(NOT _exit_code STREQUAL "0")
      message(FATAL_ERROR "
      [${_pkg}] installation errors:
        ${_stdout}
        ${_stderr}"
      )
    endif()
  endforeach()
endfunction()
