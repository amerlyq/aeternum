#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#%SUMMARY:
#%USAGE: $ ./$0
#%DEPS:

from sdl2 import *

# FIXME: there are more pythonic ways of doing this, by using the sdl2.ext module.

__appname__ = fs.basename(__file__)
__appname__ + """
"""

X = SDL_WINDOWPOS_UNDEFINED
Y = SDL_WINDOWPOS_UNDEFINED
W = 960
H = 540
FLAGS = SDL_WINDOW_SHOWN


def main():
    SDL_Init(SDL_INIT_VIDEO)

    win = SDL_CreateWindow(b"SDL2", X, Y, W, H, FLAGS)
    ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)
    bmp = SDL_LoadBMP(b"../../_rc/img/cat.bmp")
    tex = SDL_CreateTextureFromSurface(ren, bmp)
    SDL_FreeSurface(bmp)

    for i in range(20):
        SDL_RenderClear(ren)
        SDL_RenderCopy(ren, tex, None, None)
        SDL_RenderPresent(ren)
        SDL_Delay(100)

    SDL_DestroyTexture(tex)
    SDL_DestroyRenderer(ren)
    SDL_DestroyWindow(win)
    SDL_Quit()

if __name__ == "__main__":
    main()
