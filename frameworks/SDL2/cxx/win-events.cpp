//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: poll different events
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

#include <iostream>

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window* window = SDL_CreateWindow(
            "SDL2 events", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_RESIZABLE);

    // NOTE: main event loop
    SDL_Event e;
    while (e.type != SDL_KEYDOWN && e.type != SDL_QUIT) {
        while (SDL_PollEvent(&e)) {
            switch (e.type) {
            case SDL_WINDOWEVENT: {
                SDL_Window* tgtWnd = SDL_GetWindowFromID(e.window.windowID);
                const char* title = SDL_GetWindowTitle(tgtWnd);
                switch (e.window.event) {
                case SDL_WINDOWEVENT_FOCUS_GAINED: std::cout << "focus gained: " << title << std::endl; break;
                case SDL_WINDOWEVENT_FOCUS_LOST: std::cout << "focus lost: " << title << std::endl; break;
                }
            } break;
            }
            SDL_Delay(10);
        }
    }

    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
