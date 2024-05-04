//bin/mkdir -p "${TMPDIR:-/tmp}/${display:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$display" CFLAGS=-pthread "$@"
// vim:ft=c
//---
// SUMMARY: create thread
// USAGE: $ ./$0
//---
#include "errlogmacro.h"

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static volatile sig_atomic_t g_last_signo = 0;
static void signal_handler(int signo) {
    g_last_signo = signo;
}

int main() {
    // NOTE: both SIGTERM and SIGINT will cleanly terminate app
    sigset_t set;
    ERRNO_CALL(sigemptyset, &set);
    ERRNO_CALL(sigaddset, &set, SIGINT);
    struct sigaction act = {.sa_flags = 0, .sa_handler = &signal_handler, .sa_mask = set};
    ERRNO_CALL(sigaction, SIGTERM, &act, NULL);
    while (g_last_signo == 0) {
        printf(".");
        fflush(stdout);
        usleep(100000);
    }
    printf("\nend\n");
    return EXIT_SUCCESS;
}
