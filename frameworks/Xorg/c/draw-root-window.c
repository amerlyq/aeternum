//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CFLAGS=-g LDFLAGS="-lX11 -lcairo" "$@"
// vim:ft=c
//---
// SUMMARY: draw on top of root window
// SRC: https://stackoverflow.com/questions/7165408/how-to-draw-directly-on-the-desktop/7688473#7688473
// USAGE: $ DISPLAY=:1 ./$0
//---
#include <assert.h>
#include <stdio.h>
#include <X11/Xlib.h>
#include <cairo/cairo.h>
#include <cairo/cairo-xlib.h>

int width, height;

void draw(cairo_t *cr) {
    int quarter_w = width / 4;
    int quarter_h = height / 4;
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
    cairo_rectangle(cr, quarter_w, quarter_h, quarter_w * 2, quarter_h * 2);
    cairo_fill(cr);
}

int main() {
    Display *d = XOpenDisplay(NULL);
    assert(d);

    int s = DefaultScreen(d);
    Window w = RootWindow(d, s);
    width = DisplayWidth(d, s);
    height = DisplayHeight(d, s);

    cairo_surface_t *surf = cairo_xlib_surface_create(d, w,
                                  DefaultVisual(d, s),
                                  width, height);
    cairo_t *cr = cairo_create(surf);

    XSelectInput(d, w, ExposureMask);

    draw(cr);

    XEvent ev;
    while (1) {
    XNextEvent(d, &ev);
        printf("Event!\n");
        if (ev.type == Expose) {
            draw(cr);
        }
    }

    cairo_destroy(cr);
    cairo_surface_destroy(surf);
    XCloseDisplay(d);
    return 0;
}
