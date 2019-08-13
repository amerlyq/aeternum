//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: fetch system info
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>
#include <SDL2/SDL_syswm.h>

#include <iostream>

static const char*
cvtSystem(SDL_SysWMinfo& info)
{
    switch (info.subsystem) {
    case SDL_SYSWM_UNKNOWN: return "an unknown system!";
    case SDL_SYSWM_WINDOWS: return "Microsoft Windows(TM)";
    case SDL_SYSWM_X11: return "X Window System";
    case SDL_SYSWM_DIRECTFB: return "DirectFB";
    case SDL_SYSWM_COCOA: return "Apple OS X";
    case SDL_SYSWM_UIKIT: return "UIKit";
    }
    return "Error";
}

int
main(int argc, char** argv)
{
    SDL_Init(0);
    SDL_Window* window = SDL_CreateWindow("", 0, 0, 0, 0, SDL_WINDOW_HIDDEN);

    SDL_SysWMinfo info;
    SDL_VERSION(&info.version);  // get version

    if (!SDL_GetWindowWMInfo(window, &info)) {
        std::cout << "Err: " << SDL_GetError();
        exit(1);
    }
    std::cout << "SDL version=" << (int)info.version.major << "." << (int)info.version.minor << "."
              << (int)info.version.patch << " system=" << cvtSystem(info) << std::endl;

    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
