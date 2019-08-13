//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS="-lSDL2 -lGL" "$@"
// vim:ft=cpp
//---
// SUMMARY: create old OpenGL context
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>

#include <iostream>

void
init()
{
    glMatrixMode(GL_PROJECTION | GL_MODELVIEW);
    glLoadIdentity();
    glOrtho(-320, 320, 240, -240, 0, 1);
}

void
draw()
{
    static float x = 0.0, y = 30.0;
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glRotatef(10.0, 0.0, 0.0, 1.0);

    // OBSOLETE: must use extensions or newer standard SEE: SDL_GL_GetProcAddress()
    glBegin(GL_TRIANGLES);
    glColor3f(1.0, 0.0, 0.0);
    glVertex2f(x, y + 90.0);
    glColor3f(0.0, 1.0, 0.0);
    glVertex2f(x + 90.0, y - 90.0);
    glColor3f(0.0, 0.0, 1.0);
    glVertex2f(x - 90.0, y - 90.0);
    glEnd();
}

int
main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_VIDEO);

    // ATT: must be SDL_WINDOW_OPENGL
    SDL_Window* window = SDL_CreateWindow("SDL2 OpenGL",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            800,
            600,
            SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);

    if (!window) {
        std::cout << "Err: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return EXIT_FAILURE;
    }

    // NOTE: create an OpenGL context associated with the window
    SDL_GLContext glcontext = SDL_GL_CreateContext(window);

    init();
    SDL_Event e;
    while (e.type != SDL_KEYDOWN && e.type != SDL_QUIT) {
        while (SDL_PollEvent(&e))
            ;
        draw();
        SDL_GL_SwapWindow(window);
        SDL_Delay(10);
    }

    SDL_GL_DeleteContext(glcontext);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
