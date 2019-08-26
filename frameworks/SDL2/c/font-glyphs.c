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
// SUMMARY: draw text by prerendered glyphs (performance)
// USAGE: $ ./$0
// PERF:CHECK: maybe this method is even slower than directly rendering from zero each time
//---

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

SDL_Texture*
font2texture(SDL_Renderer* renderer,
        char const* const text,
        char const* const fontfile,
        int const fontsize,
        SDL_Color color)
{
    TTF_Font* font = TTF_OpenFont(fontfile, fontsize);

    int w = 0, h = 0;
    TTF_SizeText(font, text, &w, &h);

    SDL_Surface* surf = TTF_RenderText_Blended_Wrapped(font, text, color, 0x10 * (w / (0x80 - 0x20)));
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surf);

    SDL_FreeSurface(surf);
    TTF_CloseFont(font);
    return texture;
}

void
splice_texture(SDL_Texture* texture, SDL_Rect* const clips, int const N, int const M)
{
    SDL_Rect dest = {.x = 0, .y = 0};
    SDL_QueryTexture(texture, NULL, NULL, &dest.w, &dest.h);

    int k = 0;
    int dw = dest.w / N;
    int dh = dest.h / M;
    for (int j = 0; j < M; ++j) {
        for (int i = 0; i < N; ++i) {
            clips[k].x = i * dw;
            clips[k].y = j * dh;
            clips[k].w = dw;
            clips[k].h = dh;
            // DEBUG: SDL_Log("%d,%d,%d,%d\n", clips[k].x, clips[k].y, clips[k].w, clips[k].h);
            k++;
        }
    }
}

SDL_Texture*
make_glyphs(SDL_Renderer* renderer, SDL_Rect* const clips)
{
    char alphabet[0x61] = {0};
    alphabet[0] = ' ';
    int k = 1;
    for (int i = 1; i < 0x60; ++i) {
        if (0 == i % 0x10)
            alphabet[k++] = '\n';
        alphabet[k++] = (char)(i + 0x20);
    }
    alphabet[k++] = '\0';
    // DEBUG: SDL_Log("%s\n", alphabet);

    char const* fontfile = "/usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf";
    SDL_Color color = {.r = 255, .g = 155, .b = 55, .a = 255};
    SDL_Texture* texture = font2texture(renderer, alphabet, fontfile, 24, color);

    splice_texture(texture, clips, 16, 6);
    return texture;
}

int
main()
{
    SDL_Init(SDL_INIT_VIDEO);
    TTF_Init();

    SDL_Window* screen = SDL_CreateWindow("SDL2_font", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
    SDL_Renderer* renderer = SDL_CreateRenderer(screen, -1, SDL_RENDERER_SOFTWARE);

    SDL_Rect clips[16 * 6] = {0};
    SDL_Texture* texture = make_glyphs(renderer, clips);

    SDL_Event e = {};
    do {
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);

        // BET: replace by current time with milliseconds
        char buf[10] = {0};
        int bufN = sprintf(buf, "%3.4f", 13.12355f);
        SDL_Rect dst = {40, 40, clips[0].w, clips[0].h};

        for (int i = 0; i < bufN; ++i) {
            dst.x = 40 + i * dst.w;
            SDL_RenderCopy(renderer, texture, &clips[buf[i] - ' '], &dst);
        }

        SDL_RenderPresent(renderer);
        SDL_WaitEvent(&e);
    } while (e.type != SDL_QUIT && (e.type != SDL_KEYDOWN || e.key.keysym.sym != SDLK_ESCAPE));

    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(screen);
    TTF_Quit();
    SDL_Quit();
    return 0;
}
