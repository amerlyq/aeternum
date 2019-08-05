//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" LDFLAGS=-lecl "$@"
// vim:ft=c
//---
// SUMMARY: interacting with embedded Lisp
// USAGE: $ ./$0
// DEPS: |extra/ecl|
// DEBUG:
//---
#include <ecl/ecl.h>

int main(int argc, char **argv) {
    cl_boot(argc, argv);
    cl_eval(c_string_to_object("(defun aaa ()"
                               "  (write-line \"aaa\")"
                               "  (values))"));
    cl_eval(c_string_to_object("(aaa)"));
    cl_shutdown();
    return 0;
}
