//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS="-lSDL2 -lGL -lGLU" "$@"
// vim:ft=cpp
//---
// SUMMARY: create new OpenGL context
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>

#include <GL/glu.h>

#include <iostream>

void
init(int w, int h)
{
    glViewport(0, 0, w, h);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(80, (float)w / h, 0.1, 100);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    // NOTE: draw wireframe
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
}

// void
// draw(GLfloat x, GLfloat y, GLfloat z)
// {
//     glMatrixMode(GL_MODELVIEW);
//     glPushMatrix();
//     glTranslatef(x, y, z);

//     // NOTE: newer API instead of obsolete glBegin..glEnd
//     glEnableClientState(GL_VERTEX_ARRAY);
//     glEnableClientState(GL_NORMAL_ARRAY);
//     glEnableClientState(GL_TEXTURE_COORD_ARRAY);

//     glVertexPointer(3, GL_FLOAT, 0, &vertices[0]);
//     glNormalPointer(GL_FLOAT, 0, &normals[0]);
//     glTexCoordPointer(2, GL_FLOAT, 0, &texcoords[0]);
//     glDrawElements(GL_QUADS, indices.size(), GL_UNSIGNED_SHORT, &indices[0]);
//     glPopMatrix();
// }

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
    auto qObj = gluNewQuadric();

    int w, h;
    SDL_GetWindowSize(window, &w, &h);
    init(w, h);
    SDL_Event e;
    bool running = true;
    while (running) {
        while (SDL_PollEvent(&e))
            if (e.type == SDL_QUIT || (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE))
                running = false;

        glColor3f(0.0f, 0.5f, 0.5f);
        gluSphere(qObj, 1.0f, 1, 1);

        // draw(0, 0.5f, 0);
        SDL_GL_SwapWindow(window);
    }

    gluDeleteQuadric(qObj);
    SDL_GL_DeleteContext(glcontext);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
