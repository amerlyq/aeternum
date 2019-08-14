//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS="-lSDL2 -lGLEW -lGL -lCg -lCgGL" "$@"
// vim:ft=cpp
//---
// SUMMARY: create multiple OpenGL windows
// USAGE: $ ./$0
// REF:(c): ... ???
//---
// ATT: must be included before any other <gl.h>
#include <GL/glew.h>

#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>

#include <Cg/cg.h>
#include <Cg/cgGL.h>

#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

int
main()
{
    SDL_Window* mainWindow;
    SDL_Window* window2;

    SDL_GLContext mainContext;
    SDL_GLContext context2;

    SDL_Init(SDL_INIT_VIDEO);

    SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);

    mainWindow = SDL_CreateWindow("Test",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            640,
            480,
            SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    mainContext = SDL_GL_CreateContext(mainWindow);
    SDL_GL_MakeCurrent(mainWindow, mainContext);

    window2 = SDL_CreateWindow("Test2",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            640,
            480,
            SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    SDL_GL_SetAttribute(SDL_GL_SHARE_WITH_CURRENT_CONTEXT, 1);
    context2 = SDL_GL_CreateContext(window2);

    // glewExperimental = GL_TRUE;
    SDL_GL_MakeCurrent(mainWindow, mainContext);

    glewInit();

    _CGcontext* cgContext;
    cgContext = cgCreateContext();
    cgGLRegisterStates(cgContext);

    CGerror error;
    CGeffect effect;
    const char* string;
    std::string shader;

    shader = "struct VS_INPUT"
             "{"
             "   float3 pos                  : ATTR0;"
             "};"

             "struct FS_INPUT"
             "{"
             "   float4 pos                  : POSITION;"
             "   float2 tex                  : TEXCOORD0;"
             "};"

             "struct FS_OUTPUT"
             "{"
             "   float4 color                : COLOR;"
             "};"

             "FS_INPUT VS( VS_INPUT In )"
             "{"
             "   FS_INPUT Out;"
             "   Out.pos = float4( In.pos, 1.0f );"
             "   Out.tex = float2( 0.0f, 0.0f );"
             "   return Out;"
             "}"

             "FS_OUTPUT FS( FS_INPUT In )"
             "{"
             "   FS_OUTPUT Out;"
             "   Out.color = float4(1.0f, 0.0f, 0.0f, 1.0f);"
             "   return Out;"
             "}"

             "technique t0"
             "{"
             "   pass p0"
             "   {"
             "      VertexProgram = compile gp4vp VS();"
             "      FragmentProgram = compile gp4fp FS();"
             "   }"
             "}";

    effect = cgCreateEffect(cgContext, shader.c_str(), NULL);
    error = cgGetError();
    if (error) {
        string = cgGetLastListing(cgContext);
        fprintf(stderr, "Shader compiler: %s\n", string);
    }

    float* vert = new float[9];

    vert[0] = 0.0;
    vert[1] = 0.5;
    vert[2] = -1.0;
    vert[3] = -1.0;
    vert[4] = -0.5;
    vert[5] = -1.0;
    vert[6] = 1.0;
    vert[7] = -0.5;
    vert[8] = -1.0;

    glViewport(0, 0, 640, 480);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    unsigned int m_vaoID;
    unsigned int m_vboID;

    glGenVertexArrays(1, &m_vaoID);
    glBindVertexArray(m_vaoID);

    glGenBuffers(1, &m_vboID);

    glBindBuffer(GL_ARRAY_BUFFER, m_vboID);
    glBufferData(GL_ARRAY_BUFFER, 9 * sizeof(GLfloat), vert, GL_STATIC_DRAW);

    delete[] vert;

    bool quit = false;
    SDL_Event e;
    while (!quit) {
        SDL_WaitEvent(&e);

        if (e.type == SDL_QUIT || (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE))
            quit = true;

        // Draw to first window/context
        SDL_GL_MakeCurrent(mainWindow, mainContext);

        glClearColor(0.0, 0.0, 1.0, 1.0);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
        glEnableVertexAttribArray(0);

        CGtechnique tech = cgGetFirstTechnique(effect);
        CGpass pass = cgGetFirstPass(tech);
        while (pass) {
            cgSetPassState(pass);
            glDrawArrays(GL_TRIANGLES, 0, 3);
            cgResetPassState(pass);
            pass = cgGetNextPass(pass);
        }

        glDisableVertexAttribArray(0);
        glBindVertexArray(0);

        SDL_GL_SwapWindow(mainWindow);

        // Draw to second window/context
        SDL_GL_MakeCurrent(window2, context2);

        glClearColor(0.0, 0.0, 1.0, 1.0);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
        glEnableVertexAttribArray(0);

        CGtechnique tech2 = cgGetFirstTechnique(effect);
        CGpass pass2 = cgGetFirstPass(tech2);
        while (pass2) {
            cgSetPassState(pass2);
            glDrawArrays(GL_TRIANGLES, 0, 3);
            cgResetPassState(pass2);
            pass2 = cgGetNextPass(pass2);
        }

        glDisableVertexAttribArray(0);
        glBindVertexArray(0);

        SDL_GL_SwapWindow(window2);
    }

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDeleteBuffers(1, &m_vboID);
    glDeleteVertexArrays(1, &m_vaoID);

    SDL_GL_DeleteContext(mainContext);
    SDL_DestroyWindow(mainWindow);
    SDL_GL_DeleteContext(context2);
    SDL_DestroyWindow(window2);
    SDL_Quit();

    return 0;
}
