//bin/mkdir -p "${TMPDIR:-/tmp}/${display:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$display" CFLAGS=-pthread "$@"
// vim:ft=c
//---
// SUMMARY: global vars in thread
// USAGE: $ ./$0
//---
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

static int g = 0;

void* myproc(void* vargp) {
    static int s = 0;
    printf("Thread ID: %d, Static: %d, Global: %d\n", (long)vargp, ++s, ++g);
}

int main() {
    pthread_t tid;

    for (long i = 0; i < 3; i++)
        pthread_create(&tid, NULL, myproc, (void*)i);

    pthread_exit(NULL);
    return 0;
}
