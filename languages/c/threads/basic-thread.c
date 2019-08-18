//bin/mkdir -p "${TMPDIR:-/tmp}/${display:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$display" CFLAGS=-pthread "$@"
// vim:ft=c
//---
// SUMMARY: create thread
// USAGE: $ ./$0
//---
#include <pthread.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> /*  for sleep()  */

void* my_procedure(void* vargp) {
    sleep(1);
    printf("thread\n");
    return NULL;
}

int main() {
    pthread_t tid;
    printf("beg\n");
    pthread_create(&tid, NULL, my_procedure, NULL);
    pthread_join(tid, NULL);
    printf("end\n");
    return EXIT_SUCCESS;
}
