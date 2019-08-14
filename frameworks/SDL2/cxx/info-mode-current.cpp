//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: query current display mode
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

#include <iostream>

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    SDL_DisplayMode current;

    // Get current display mode of all displays.
    for (int i = 0; i < SDL_GetNumVideoDisplays(); ++i) {
        if (SDL_GetCurrentDisplayMode(i, &current)) {
            std::cout << "Err(#" << i << "): " << SDL_GetError();
        } else {
            std::cout << "display=" << i << " mode=" << current.w << 'x' << current.h << "px @ " << current.refresh_rate
                      << "hz" << std::endl;
        }
    }

    SDL_Quit();
    return EXIT_SUCCESS;
}
