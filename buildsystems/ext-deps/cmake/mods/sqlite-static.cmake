# SUMMARY: we build our own static sqlite3 library with custom flags
# WARN: both "PkgConfig::sqlite" and ${sqlite_STATIC_LDFLAGS} are shared libraries
# TEMP:REM:HACK: replace shared library by full path to our custom static library
#   <= linker always prefers shared over static even with "-L./_prefix/lib" specified

find_package(PkgConfig MODULE REQUIRED)
pkg_check_modules(sqlite REQUIRED IMPORTED_TARGET "sqlite3 >= 3.8.7")

find_library(local_sqlite_LIBRARY NAMES sqlite3.a sqlite3 NO_CMAKE_FIND_ROOT_PATH
  NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)

set(local_sqlite_LDFLAGS ${sqlite_STATIC_LDFLAGS})
list(REMOVE_ITEM local_sqlite_LDFLAGS -lsqlite3)
list(INSERT local_sqlite_LDFLAGS 0 ${local_sqlite_LIBRARY})

target_include_directories(${PROJECT_NAME}
  PRIVATE
    ${sqlite_STATIC_INCLUDE_DIRS}
)

target_link_libraries(${PROJECT_NAME}
  PRIVATE
    ${local_sqlite_LDFLAGS}
)
