//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: poll different events
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

// TODO: other window events :: focus, etc

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window* window = SDL_CreateWindow(
            "SDL2 events", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_RESIZABLE);

    // NOTE: main event loop
    bool running = true;
    for (SDL_Event e = {}; running; SDL_Delay(10)) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT || (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE)) {
                running = false;
                break;
            }

            switch (e.type) {
            case SDL_WINDOWEVENT: {
                SDL_Window* tgtWnd = SDL_GetWindowFromID(e.window.windowID);
                const char* title = SDL_GetWindowTitle(tgtWnd);
                switch (e.window.event) {
                case SDL_WINDOWEVENT_FOCUS_GAINED: SDL_Log("focus gained: %s\n", title); break;
                case SDL_WINDOWEVENT_FOCUS_LOST: SDL_Log("focus lost: %s\n", title); break;
                }
            } break;
            }
        }
    }

    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
