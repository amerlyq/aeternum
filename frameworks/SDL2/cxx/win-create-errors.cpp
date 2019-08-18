#if 0
set -fCueEo pipefail
s=${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}
mkdir -p "${x:=${TMPDIR:-/tmp}/$s}"
make -C "$x" -sf- VPATH="${s%/*}" "${n%.*}" <<EOT
CXXFLAGS += -Wall -std=c++11 $(sdl2-config --cflags)
LDFLAGS += $(sdl2-config --libs)
EOT
exec ${RUN-} "$x/${n%.*}" "$@"
#endif
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
        SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "%s", SDL_GetError());
        exit(EXIT_FAILURE);
    }

    // Args: (title x y w h flags)
    SDL_Window* window =
            SDL_CreateWindow("SDL2", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_SHOWN);

    if (!window) {
        SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "%s", SDL_GetError());
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
