//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS="-lSDL2 -lGL" "$@"
// vim:ft=cpp
//---
// SUMMARY: flashing random colors (should work on iOS/Android/Mac/Windows/Linux)
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>

#include <cstdlib>

static bool quitting = false;
static float r = 0.0f;
static SDL_Window* window = NULL;
static SDL_GLContext gl_context;

void
render()
{
    SDL_GL_MakeCurrent(window, gl_context);

    r = static_cast<float>(rand()) / static_cast<float>(RAND_MAX);

    glClearColor(r, 0.4f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    SDL_GL_SwapWindow(window);

}

int SDLCALL
watch(void* userdata, SDL_Event* e)
{
    if (e->type == SDL_APP_WILLENTERBACKGROUND) {
        quitting = true;
    }

    return 1;
}

int
main(int argc, char* argv[])
{
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) {
        SDL_Log("Failed to initialize SDL: %s", SDL_GetError());
        return 1;
    }

    window = SDL_CreateWindow("title", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 512, 512, SDL_WINDOW_OPENGL);

    gl_context = SDL_GL_CreateContext(window);

    SDL_AddEventWatch(watch, NULL);

    while (!quitting) {

        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT || e.type == SDL_KEYDOWN) {
                quitting = true;
            }
        }

        render();
        SDL_Delay(10);
    }

    SDL_DelEventWatch(watch, NULL);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return EXIT_SUCCESS;
}
