//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: draw rect in floating window
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    auto window = SDL_CreateWindow("SDL2/rect",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            640,
            480,
            SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);

    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

    SDL_Rect raw_rect = {.x = 50, .y = 50, .w = 50, .h = 50};

    // auto texture = IMG_LoadTexture(ren,"../../_rc/img/cat.jpg")
    // SDL_Rect tex_rect = { .x = 100, .y = 100, .w = 100, .h = 100 };
    // SDL_RenderCopy(renderer, texture, NULL, &tex_rect);

    SDL_Event e = {};
    do {
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_RenderClear(renderer);

        SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
        SDL_RenderFillRect(renderer, &raw_rect);

        SDL_RenderPresent(renderer);

        SDL_WaitEvent(&e);
    } while (e.type != SDL_QUIT && (e.type != SDL_KEYDOWN || e.key.keysym.sym != SDLK_ESCAPE));

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
