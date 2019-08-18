#if 0
set -fCueEo pipefail
s=${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}
mkdir -p "${x:=${TMPDIR:-/tmp}/$s}"
make -C "$x" -sf- VPATH="${s%/*}" "${n%.*}" <<EOT
CXXFLAGS += -std=c++11 -DSRCPATH='"$s"'
LDFLAGS += -lSDL2 -lSDL2_ttf
EOT
exec ${RUN-} "$x/${n%.*}" "$@"
#endif
// vim:ft=cpp
//---
// SUMMARY: draw text
// USAGE: $ ./$0
//---

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

int
main()
{
    SDL_Init(SDL_INIT_VIDEO);
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        SDL_Log("Could not init SDL: %s", SDL_GetError());
        return EXIT_FAILURE;
    }
    if (TTF_Init() != 0) {
        SDL_Log("Couldn't init SDL_ttf: %s", TTF_GetError());
        return EXIT_FAILURE;
    }
    TTF_Font* font = TTF_OpenFont("/usr/share/fonts/TTF/DejaVuSans.ttf", 72);
    if (!font) {
        SDL_Log("Couldn't load font");
        return EXIT_FAILURE;
    }
    SDL_Window* screen =
            SDL_CreateWindow("SDL2_font", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
    if (!screen) {
        SDL_Log("Could not create window");
        return EXIT_FAILURE;
    }
    SDL_Renderer* renderer = SDL_CreateRenderer(screen, -1, SDL_RENDERER_SOFTWARE);
    if (!renderer) {
        SDL_Log("Could not create renderer");
        return EXIT_FAILURE;
    }

    SDL_Color col_white = { .r = 255, .g = 255, .b = 255, .a = 255 };
    SDL_Surface* text = TTF_RenderUTF8_Blended(font, "Hello world", col_white);
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, text);
    SDL_FreeSurface(text);
    text = NULL;

    SDL_Rect dest = { .x = 10, .y = 10 };
    SDL_QueryTexture(texture, NULL, NULL, &dest.w, &dest.h);

    SDL_Event e = {};
    do {
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, &dest);
        SDL_RenderPresent(renderer);

        SDL_WaitEvent(&e);
    } while (e.type != SDL_QUIT && (e.type != SDL_KEYDOWN || e.key.keysym.sym != SDLK_ESCAPE));

    SDL_DestroyTexture(texture);
    SDL_DestroyWindow(screen);
    TTF_CloseFont(font);
    TTF_Quit();
    SDL_Quit();
    return 0;
}
