//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: pseudo-fullscreen window
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    int const default_display = 0;
    SDL_DisplayMode displayMode;
    int request = SDL_GetDesktopDisplayMode(default_display, &displayMode);
    if (request) {
        SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "%s", SDL_GetError());
        exit(EXIT_FAILURE);
    }

    auto window = SDL_CreateWindow("SDL2/full", 0, 0, displayMode.w, displayMode.h, SDL_WINDOW_SHOWN);
    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

    SDL_Event e = {};
    do {
        SDL_SetRenderDrawColor(renderer, 45, 125, 50, 255);
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);

        SDL_WaitEvent(&e);
    } while (e.type != SDL_QUIT && (e.type != SDL_KEYDOWN || e.key.keysym.sym != SDLK_ESCAPE));

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
