//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++14 LDFLAGS=-lSDL2 "$@"
// vim:ft=cpp
//---
// SUMMARY: get input
// USAGE: $ ./$0
// SEE: ~/sdk/SDL2-2.0.10/test/checkkeys.c
//---
#include <SDL2/SDL.h>

#include <string>

// TODO: mouse-move, gamepad, etc. input

auto
getMods(SDL_Keymod mod)
{
    std::string mods;
    if (mod & KMOD_LSHIFT)
        mods += " LShift";
    if (mod & KMOD_RSHIFT)
        mods += " RShift";
    if (mod & KMOD_LCTRL)
        mods += " LCtrl";
    if (mod & KMOD_RCTRL)
        mods += " RCtrl";
    if (mod & KMOD_LALT)
        mods += " LAlt";
    if (mod & KMOD_RALT)
        mods += " RAlt";
    if (mod & KMOD_LGUI)
        mods += " LGui";
    if (mod & KMOD_RGUI)
        mods += " RGui";
    if (mod & KMOD_NUM)
        mods += " Num";
    if (mod & KMOD_CAPS)
        mods += " Caps";
    if (mod & KMOD_MODE)
        mods += " Mode";
    return mods;
}

auto
getDirs(Uint8 const* keyboardState)
{
    std::string dirs;
    if (keyboardState[SDL_SCANCODE_UP] || keyboardState[SDL_SCANCODE_W])
        dirs += " ↑";
    if (keyboardState[SDL_SCANCODE_DOWN] || keyboardState[SDL_SCANCODE_S])
        dirs += " ↓";
    if (keyboardState[SDL_SCANCODE_LEFT] || keyboardState[SDL_SCANCODE_A])
        dirs += " ←";
    if (keyboardState[SDL_SCANCODE_RIGHT] || keyboardState[SDL_SCANCODE_D])
        dirs += " →";
    return dirs;
}

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window* window = SDL_CreateWindow(
            "SDL2 input", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_RESIZABLE);
    SDL_StartTextInput();

    // NOTE: bind forever
    Uint8 const* keyboardState = SDL_GetKeyboardState(NULL);

    // NOTE: main event loop
    bool running = true;
    for (SDL_Event e = {}; running; SDL_Delay(100)) {
        while (SDL_PollEvent(&e)) {
            switch (e.type) {
            case SDL_QUIT: {
                running = false;
                break;
            }
            case SDL_KEYDOWN: {
                if (e.key.keysym.sym == SDLK_ESCAPE)
                    running = false;
                auto mods = getMods(SDL_GetModState());
                SDL_Log("key: %d, mods: %s", e.key.keysym.sym, mods.c_str());
                SDL_Log("dirs: %s", getDirs(keyboardState).c_str());
            } break;
            case SDL_MOUSEBUTTONDOWN: {
                switch (e.button.button) {
                case SDL_BUTTON_LEFT: SDL_Log("mouse: left"); break;
                case SDL_BUTTON_RIGHT: SDL_Log("mouse: right"); break;
                }
                break;
            }
            case SDL_TEXTINPUT: {
                int x = 0, y = 0;
                auto key = e.text.text[0];
                SDL_GetMouseState(&x, &y);
                SDL_Log("text=%c at %d %d", key, x, y);
            } break;
            }
        }
    }

    SDL_StopTextInput();
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
