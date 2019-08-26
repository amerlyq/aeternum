//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CFLAGS=-std=c99 LDFLAGS=-lX11 "$@"
// vim:ft=c
//---
// SUMMARY: grab global key <C-S-k> -- press to exit
// USAGE: $ ./$0
// WARN: NumLock, CapsLock are counted toward modifiers table!
//  => hotkey doesn't match and isn't reported when NumLock is enabled
//---
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <stdio.h>

int
main()
{
    Display* dpy = XOpenDisplay(0);
    Window root = DefaultRootWindow(dpy);
    XEvent ev;

    unsigned int modifiers = ControlMask | ShiftMask;
    int keycode = XKeysymToKeycode(dpy, XK_K);
    Window grab_window = root;
    Bool owner_events = False;
    int pointer_mode = GrabModeAsync;
    int keyboard_mode = GrabModeAsync;

    XGrabKey(dpy, keycode, modifiers, grab_window, owner_events, pointer_mode, keyboard_mode);

    XSelectInput(dpy, root, KeyPressMask);

    int running = 1;
    while (running) {
        XNextEvent(dpy, &ev);
        switch (ev.type) {
        case KeyPress: {
            printf("Hot key pressed!\n");
            XUngrabKey(dpy, keycode, modifiers, grab_window);
            running = 0;
        } break;
        default: break;
        }
    }

    XCloseDisplay(dpy);
    return 0;
}
