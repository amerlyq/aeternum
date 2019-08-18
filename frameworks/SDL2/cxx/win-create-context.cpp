//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++17 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: create window and exit after timeout
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

#include <functional>
#include <memory>

// TRY: encompass this ::
//   https://github.com/xyproto/sdl2-examples/blob/master/include/sdl2.h
//   https://github.com/xyproto/sdl2-examples/blob/master/c%2B%2B17-cxx/main.cpp

template <typename T>
auto
make_resource(T object, std::function<void(T)> dtor)
{
    if (!object) {
        SDL_Log("Err: %s", SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }
    return std::unique_ptr<T, std::function<void(T)>>(std::move(object), std::move(dtor));
}

template <typename T>
auto
make_resource(T object, std::function<void(void)> dtor)
{
    return make_resource<T>(std::move(object), [=](T) { dtor(); });
}

int
main(int argc, char** argv)
{
    auto const sdl = make_resource(SDL_Init(SDL_INIT_VIDEO), SDL_Quit);
    auto const window = make_resource(
            SDL_CreateWindow("SDL2", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_SHOWN),
            SDL_DestroyWindow);

    SDL_Delay(2000);
    SDL_Quit();
    return EXIT_SUCCESS;
}
