//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CFLAGS=-std=c99 LDFLAGS=-lX11 "$@"
// vim:ft=c
//---
// SUMMARY: listen keypress on desktop only (root window)
// USAGE: $ DISPLAY=:1 ./$0
// SRC: https://gist.github.com/javiercantero/7753445
//---
#include <X11/Xlib.h>
#include <X11/Xos.h>
#include <X11/Xutil.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int
main(void)
{
    Display* d;
    Window r;
    XEvent e;
    KeySym key;
    char text[256];

    d = XOpenDisplay(NULL);
    if (d == NULL) {
        fprintf(stderr, "Cannot open display\n");
        exit(1);
    }

    r = DefaultRootWindow(d);
    XSelectInput(d, r, KeyPressMask | KeyReleaseMask);

    XSync(d, False);
    while (!XNextEvent(d, &e)) {
        if (e.type == KeyPress && XLookupString(&e.xkey, text, 255, &key, 0) == 1) {
            if (text[0] == 'q') {
                break;
            }
            printf("'%c' key!\n", text[0]);
        } else {
            printf("event '%d'\n", e.type);
        }
    }

    XCloseDisplay(d);
    return 0;
}
