//bin/mkdir -p "${TMPDIR:-/tmp}/${display:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$display" CXXFLAGS=-std=c99 LDFLAGS=-lX11 "$@"
// vim:ft=c
//---
// SUMMARY: draw a box in a window.
// USAGE: $ ./$0
//---
#include <X11/Xlib.h>
#include <X11/Xos.h>
#include <X11/Xutil.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char * const kMsg = "Hello, World!";

int
main(void)
{
    Display* display = XOpenDisplay(NULL);
    if (display == NULL) {
        fprintf(stderr, "Cannot open display\n");
        exit(1);
    }

    int screen = DefaultScreen(display);
    Window window = XCreateSimpleWindow(display,
            RootWindow(display, screen),
            10,
            10,
            400,
            400,
            1,
            BlackPixel(display, screen),
            WhitePixel(display, screen));

    // VIZ: select events
    // XSelectInput(display, window, FocusChangeMask | PropertyChangeMask);
    // XSelectInput(display, window, VisibilityChangeMask | ResizeRedirectMask);
    // XSelectInput(display, window, PointerMotionMask | Button1MotionMask);
    // XSelectInput(display, window, EnterWindowMask | LeaveWindowMask);
    XSelectInput(display, window, ExposureMask | KeyPressMask | VisibilityChangeMask | ResizeRedirectMask);
    XMapWindow(display, window);

    // main event loop
    XEvent e;
    KeySym key;
    char text[256];

    while (1) {
        XNextEvent(display, &e);
        /* draw or redraw the window */
        if (e.type == Expose && e.xexpose.count == 0) {
            XFillRectangle(display, window, DefaultGC(display, screen), 20, 20, 10, 10);
            XDrawString(display, window, DefaultGC(display, screen), 50, 50, kMsg, strlen(kMsg));
        } else if (e.type == KeyPress && XLookupString(&e.xkey, text, 255, &key, 0) == 1) {
            /* use the XLookupString routine to convert the invent
              KeyPress data into regular text.  Weird but necessary...
            */
            if (text[0] == 'q') {
                break;
            }
            printf("You pressed the %c key!\n", text[0]);
        } else if (e.type == ButtonPress) {
            /* tell where the mouse Button was Pressed */
            printf("You pressed a button at (%i,%i)\n", e.xbutton.x, e.xbutton.y);
        } else {
            printf("%d\n", e.type);
        }
    }

    XCloseDisplay(display);
    return EXIT_SUCCESS;
}
