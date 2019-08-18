#if 0
b=${t:=${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}}/${x:=${n%.*}}
mkdir -p "$t" && cd "$t" && make -srRf- s="$0" x="$x" <<'EOT' && exec ./"$x" "$@" || exit
CC := gcc
CFLAGS += -Wall -std=c11

$(x): $(s) lib$(x).so \
; $(CC) $(CFLAGS) -pthread -DMAIN_C $(LDFLAGS) -Wl,-rpath=. -L. '$<' $(LDLIBS) -l$(x) -o '$@'

lib$(x).so: $(s) \
; $(CC) $(CFLAGS) -shared -fPIC -DSHARED_C $(ldflags) '$<' $(ldlibs) -o '$@'
EOT
#endif
// vim:ft=c
//---
// SUMMARY: check if thread-local vars are updated on fork() and create()
// USAGE: $ ./$0
//---
// ===============================================
#ifdef SHARED_C
#define _GNU_SOURCE
#include <stdio.h>
#include <sys/types.h>
#include <syscall.h>
#include <unistd.h>

void* print_tids(void* ctx) {
    static __thread pid_t tid = 0;
    if (!tid)
        tid = syscall(SYS_gettid);
    printf("cur: %d; tid: %d\n", (int)syscall(SYS_gettid), tid);
    return NULL;
}
#endif
// ===============================================
#ifdef MAIN_C
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

extern void* print_tids(void*);

int main(int argc, char* argv[]) {
    // Fork
    print_tids(NULL);
    fork();
    print_tids(NULL);

    // Thread
    pthread_t tid;
    pthread_create(&tid, NULL, print_tids, NULL);
    pthread_join(tid, NULL);
    print_tids(NULL);
    return EXIT_SUCCESS;
}
#endif
