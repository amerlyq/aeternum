//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: create window and exit after timeout
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

int
main(int argc, char** argv)
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        SDL_Log("Err: %s", SDL_GetError());
        exit(EXIT_FAILURE);
    }

    // Args: (title x y w h flags)
    SDL_Window* window =
            SDL_CreateWindow("SDL2", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_SHOWN);

    if (!window) {
        SDL_Log("Err: %s", SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }

    // OR:(simply): SDL_Delay(2000);
    for (SDL_Event e = {}; e.type != SDL_QUIT && (e.type != SDL_KEYDOWN || e.key.keysym.sym != SDLK_ESCAPE);)
        SDL_WaitEvent(&e);

    // ALT:
    // while (!quit) {
    //     SDL_Event e;
    //     SDL_WaitEvent(&e);
    //     switch (e.type) {
    //     case SDL_KEYDOWN:
    //         switch (e.key.keysym.sym) {
    //         case SDLK_ESCAPE:
    //         case SDLK_q: quit = true; break;
    //         }
    //     case SDL_QUIT: quit = true; break;
    //     }
    // }

    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
