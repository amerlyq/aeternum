//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: create window with title and exit on keypress
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>

#include <cstdlib>
#include <string>

const char* const kInitialTitle = "Initial title";

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window* window = SDL_CreateWindow(
            kInitialTitle, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_RESIZABLE);

    // HACK: wait for keypress
    for (SDL_Event e; e.type != SDL_QUIT && e.type != SDL_KEYDOWN; SDL_PollEvent(&e)) {
        SDL_SetWindowTitle(window, std::to_string(SDL_GetTicks()).c_str());
        SDL_Delay(100);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
