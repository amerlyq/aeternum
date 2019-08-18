cmake_minimum_required(VERSION 3.10)

project(main CXX)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

## ALT:USE: pkgconfig BAD: no .pc for other libs
# include(FindPkgConfig)
# pkg_search_module(SDL2 REQUIRED sdl2)

find_package(SDL2 REQUIRED)
find_package(SDL2_image REQUIRED)

# add_executable(${PROJECT_NAME} WIN32 main.cpp)
add_executable(${PROJECT_NAME} main.cpp)

target_include_directories(${PROJECT_NAME}
  PRIVATE
    ${SDL2_INCLUDE_DIRS}
    ${SDL2_IMAGE_DIRS}
)

target_link_libraries(${PROJECT_NAME}
  PRIVATE
    ${SDL2_LIBRARIES}
    ${SDL2_IMAGE_LIBRARIES}
)
