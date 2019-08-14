//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: query closest display mode
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

#include <cstdio>

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    // NOTE: bogus size and rate
    SDL_DisplayMode target = {.format = 0, .w = 1000, .h = 600, .refresh_rate = 20, .driverdata = 0};
    SDL_DisplayMode closest;

    printf("Requesting: %dx%dpx @ %dhz\n", target.w, target.h, target.refresh_rate);
    if (!SDL_GetClosestDisplayMode(0, &target, &closest)) {
        fprintf(stderr, "No match was found!\n");
        SDL_Quit();
        return EXIT_FAILURE;
    }
    printf("Closest: %dx%dpx @ %dhz\n", closest.w, closest.h, closest.refresh_rate);

    SDL_Window* window = SDL_CreateWindow("SDL2 Window",
            closest.w,
            closest.h,
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOW_FULLSCREEN);

    if (!SDL_SetWindowDisplayMode(window, &closest)) {
        fprintf(stderr, "Can't setup display mode\n");
        SDL_Quit();
        return EXIT_FAILURE;
    }

    SDL_Delay(1000);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
