//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: draw rect
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

int
main(int argc, char** argv)
{
    auto window = SDL_CreateWindow(
            "Rect", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_SHOWN);

    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
    SDL_RenderClear(renderer);

    SDL_Rect r = { .x = 50, .y = 50, .w = 50, .h = 50 };
    SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
    SDL_RenderFillRect(renderer, &r);

    SDL_RenderPresent(renderer);
    SDL_Delay(3000);

    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
