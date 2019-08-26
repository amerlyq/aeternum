#if 0
set -fCueEo pipefail
s=${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}
mkdir -p "${x:=${TMPDIR:-/tmp}/$s}"
make -C "$x" -sf- VPATH="${s%/*}" "${n%.*}" <<EOT
CXXFLAGS += -std=c99
LDFLAGS += -lSDL2 -lSDL2_ttf
EOT
exec ${RUN-} "$x/${n%.*}" "$@"
#endif
// vim:ft=c
//---
// SUMMARY: draw wrapped text
// USAGE: $ ./$0
//---

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

char const* const kFontFile = "/usr/share/fonts/TTF/DejaVuSans.ttf";

int
main()
{
    SDL_Init(SDL_INIT_VIDEO);
    TTF_Init();
    TTF_Font* font = TTF_OpenFont(kFontFile, 72);
    SDL_Window* screen = SDL_CreateWindow("SDL2_font", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
    SDL_Renderer* renderer = SDL_CreateRenderer(screen, -1, SDL_RENDERER_SOFTWARE);

    char const* text = "Neverending stream of tears";
    int w = 0, h = 0;
    TTF_SizeText(font, text, &w, &h);

    SDL_Color color = {.r = 255, .g = 255, .b = 255, .a = 255};
    SDL_Surface* surf = TTF_RenderText_Blended_Wrapped(font, text, color, w / 2);
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surf);
    SDL_FreeSurface(surf);
    surf = NULL;

    SDL_Rect dest = {.x = 10, .y = 10};
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
