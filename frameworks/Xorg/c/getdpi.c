//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-g LDFLAGS=-lX11 "$@"
// vim:ft=c
//---
// SUMMARY: print DPI of all screens
// USAGE: $ ./$0
//---
#include <X11/Xlib.h>

#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char** argv)
{
    Display* dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "xdpi:  unable to open default display \"%s\".\n", XDisplayName(NULL));
        exit(1);
    }

    for (int scr = 0; scr < ScreenCount(dpy); ++scr) {
        int w = DisplayWidth(dpy, scr);
        int h = DisplayHeight(dpy, scr);
        int mw = DisplayWidthMM(dpy, scr);
        int mh = DisplayHeightMM(dpy, scr);
        int xdpi = 0.5 + 25.4 * w / mw;
        int ydpi = 0.5 + 25.4 * h / mh;
        printf("xdpi=%d ydpi=%d\n", xdpi, ydpi);
    }

    return EXIT_SUCCESS;
}
