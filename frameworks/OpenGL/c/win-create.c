#if 0
set -fCueEo pipefail
s=${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}
mkdir -p "${x:=${TMPDIR:-/tmp}/$s}"
make -C "$x" -sf- VPATH="${s%/*}" "${n%.*}" <<EOT
CXXFLAGS += -std=c99 -DSRCPATH='"$s"'
LDFLAGS += -lglfw -lGL
EOT
exec ${RUN-} "$x/${n%.*}" "$@"
#endif
// vim:ft=c
//---
// SUMMARY: create basic window
// USAGE: $ ./$0
// REF: https://www.glfw.org/docs/latest/
//---
#include <GLFW/glfw3.h>

int
main(void)
{
    GLFWwindow* window;

    if (!glfwInit())
        return -1;

    window = glfwCreateWindow(640, 480, "GLFW", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}
