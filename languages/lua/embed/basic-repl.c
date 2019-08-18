//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" LDFLAGS=-llua "$@"
// vim:ft=c
//---
// SUMMARY: evaluate REPL with Lua expr inside C runtime
// USAGE: $ ./$0
//---
#include <lauxlib.h>
#include <lualib.h>
#include <lua.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    char buff[256];
    int error;

    lua_State *L = luaL_newstate(); /* opens Lua */
    luaopen_base(L);                /* opens the basic library */
    luaopen_table(L);               /* opens the table library */
    luaopen_io(L);                  /* opens the I/O library */
    luaopen_string(L);              /* opens the string lib. */
    luaopen_math(L);                /* opens the math lib. */

    while (fgets(buff, sizeof(buff), stdin) != NULL) {
        error = luaL_loadbuffer(L, buff, strlen(buff), "line") ||
                lua_pcall(L, 0, 0, 0);
        if (error) {
            fprintf(stderr, "%s", lua_tostring(L, -1));
            lua_pop(L, 1); /* pop error message from the stack */
        }
    }

    lua_close(L);
    return EXIT_SUCCESS;
}
