#if 0
set -fCueEo pipefail
s=${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}
mkdir -p "${x:=${TMPDIR:-/tmp}/$s}"
make -C "$x" -sf- VPATH="${s%/*}" "${n%.*}" <<EOT
CFLAGS += -std=c99 -I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include
LDFLAGS += -ldbus-glib-1 -ldbus-1 -lglib-2.0 -lgobject-2.0
EOT
exec ${RUN-} "$x/${n%.*}" "$@"
#endif
// vim:ft=c
//---
// SUMMARY: interact with dbus services
// USAGE: $ ./$0
//---
#include <dbus/dbus-glib.h>
#include <dbus/dbus.h>

#include <stdlib.h>

int
main()
{
    DBusGConnection* connection;
    GError* error;
    DBusGProxy* proxy;
    char** name_list;
    char** name_list_ptr;

#ifndef GLIB_VERSION_2_36
    g_type_init();
#endif

    error = NULL;
    connection = dbus_g_bus_get(DBUS_BUS_SYSTEM, &error);
    if (connection == NULL) {
        g_printerr("Failed to open connection to bus: %s\n", error->message);
        g_error_free(error);
        exit(EXIT_FAILURE);
    }

    // Create a proxy object for the "bus driver" (name "org.freedesktop.DBus")
    proxy = dbus_g_proxy_new_for_name(connection, "net.connman", "/", "net.connman.Clock");

    // Call ListNames method, wait for reply
    error = NULL;
    if (!dbus_g_proxy_call(proxy, "GetProperties", &error, G_TYPE_INVALID, G_TYPE_STRV, &name_list, G_TYPE_INVALID)) {
        // if (!dbus_g_proxy_call(proxy, "SetProperty", &error, G_TYPE_INVALID,
        //                        G_TYPE_STRV, &name_list, G_TYPE_INVALID)) {
        // Just do demonstrate remote exceptions versus regular GError
        if (error->domain == DBUS_GERROR && error->code == DBUS_GERROR_REMOTE_EXCEPTION)
            g_printerr("Caught remote method exception %s: %s", dbus_g_error_get_name(error), error->message);
        else
            g_printerr("Error: %s\n", error->message);
        g_error_free(error);
        exit(1);
    }

    g_print("Names on the message bus:\n");
    for (name_list_ptr = name_list; *name_list_ptr; name_list_ptr++) {
        g_print("  %s\n", *name_list_ptr);
    }
    g_strfreev(name_list);

    g_object_unref(proxy);
    return EXIT_SUCCESS;
}
