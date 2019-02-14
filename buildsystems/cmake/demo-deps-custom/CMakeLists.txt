cmake_minimum_required(VERSION 3.5)
project(mypj)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/aaa
  COMMAND touch ${CMAKE_BINARY_DIR}/aaa
)

add_custom_target(coverage
  COMMAND echo "***** coverage"
  DEPENDS ${CMAKE_BINARY_DIR}/aaa
)

file(WRITE ${PROJECT_BINARY_DIR}/mylib.h
  "int f();\n")
file(WRITE ${PROJECT_BINARY_DIR}/mylib.cpp
  "int f() { return 5; }\n")
file(WRITE ${PROJECT_BINARY_DIR}/main.cpp "\
#include \"mylib.h\"
int main() { return f(); }
")

add_library(mylib mylib.cpp)
add_executable(myexe main.cpp)
target_link_libraries(myexe mylib)

add_dependencies(mylib coverage)
