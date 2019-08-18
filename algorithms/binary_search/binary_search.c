//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
// vim:ft=c
//---
// SUMMARY: pseudo-fullscreen window
// USAGE: $ ./$0
// REF: C-function "bsearch"
//---
#include <stdio.h>
#include <stdlib.h>

int cmpfunc(const void * a, const void * b) { return ( *(int*)a - *(int*)b ); }

int main() {
    int values[] = { 5, 20, 29, 32, 63 };
    int key = 32;
    int *item = (int*) bsearch (&key, values, 5, sizeof(int), cmpfunc);
    if( item != NULL ) { printf("%d\n", *item); } else { printf("not found\n"); }
}
