project(Filter)

add_library(${PROJECT_NAME}
  src/Filter.cpp
)

target_sources(${PROJECT_NAME} PRIVATE
  src/Filter.hpp
)

target_include_directories(${PROJECT_NAME}
  PUBLIC
    src
)

target_link_libraries(${PROJECT_NAME}
  PUBLIC
    Common
  PRIVATE
    Logger
)

# NOTE: any executable == component library linked to boilerplate .cpp file
#   => each .cpp must reimplement main(), args processing, textual help, and signal handlers
add_executable(${PROJECT_NAME}-exe ${PROJECT_NAME}.cpp)
target_link_libraries(${PROJECT_NAME}-exe PRIVATE ${PROJECT_NAME})
set_target_properties(${PROJECT_NAME}-exe PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
install(TARGETS ${PROJECT_NAME}-exe DESTINATION bin)
