//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS='-std=c++11 -O3' "$@"
// vim:ft=cpp
//---
// SUMMARY: bicoin benchmark -- find out the higher bit
// USAGE: $ ./$0
// PERF: i5-4500
//  0: time=128.880491
//  1: time=17.813954
//  2: time=26.523264
//  3: time=62.499621
//  4: time=22.520085
//  5: time=12.685275
//  6: time=12.684535
// PERF: i7-6700
//  0: time=51.620868
//  1: time=9.445744
//  2: time=13.826354
//  3: time=10.070999
//  4: time=12.728914
//  5: time=7.998600
//  6: time=6.728109
//  Raw asm: time=2.797641
//---
#include <stdio.h>
#include <time.h>
#include <stdint.h>

uint32_t bits0(uint32_t num) {
    int count = 0;
    while(num) num >>=1, ++count;
    return count;
}

uint32_t bits1(uint32_t num) {
    if (!num)
        return 0;
    int float_order_le = 1;
    union { uint32_t u[2]; double d; } t;
    t.u[float_order_le] = 0x43300000;
    t.u[!float_order_le] = num;
    t.d -= 4503599627370496.0;
    return ((t.u[float_order_le] >> 20) - 0x3FF) + 1;
}

uint32_t bits2(uint32_t num) {
    num |= num >> 1;
    num |= num >> 2;
    num |= num >> 4;
    num |= num >> 8;
    num |= num >> 16;
    uint32_t a = num;
    a = a - ((a >> 1) & 0x55555555);
    a = (a & 0x33333333) + ((a >> 2) & 0x33333333);
    a = ((a + (a >> 4) & 0xF0F0F0F) * 0x1010101) >> 24;
    return a;
}


uint32_t bits3(uint32_t v) {
    uint32_t r, shift;
    r = (v > 0xFFFF) << 4; v >>= r;
    shift = (v > 0xFF) << 3; v >>= shift; r |= shift;
    shift = (v > 0x0F) << 2; v >>= shift; r |= shift;
    shift = (v > 0x03) << 1; v >>= shift; r |= shift;
    r |= (v >> 1);
    return r + (v != 0);
}

uint32_t bits4(uint32_t num) {
    if (num == 0) return 0;
    int n = 31;
    if (num >> 16 == 0) { n -= 16; num <<= 16; }
    if (num >> 24 == 0) { n -= 8; num <<= 8; }
    if (num >> 28 == 0) { n -=  4; num <<= 4; }
    if (num >> 30 == 0) { n -=  2; num <<= 2; }
    n += num >> 31;
    return n;
}



uint32_t bits5(uint32_t num) {
   union {uint32_t asInt[2];double asDouble;} t;
   t.asDouble = (double)num; //+0.5 для коррекции
   return  (t.asInt[1] >> 20)-0x400+2;
}

uint32_t bits6(uint32_t num) {
    int msb;
    asm("bsrl %1,%0; inc %0" : "=r"(msb) : "r"(num));
    return msb;
}

double getTimerDelta()
{
    static struct timespec tc = {0, 0}, tp = {0, 0};
    double delta = 0;
    clock_gettime(CLOCK_REALTIME, &tc);
    delta = tc.tv_sec - tp.tv_sec + (tc.tv_nsec - tp.tv_nsec)/1000000000.;
    tp = tc;
    return delta;
}

typedef uint32_t (*pf)(uint32_t);

union _c {
    struct {
        unsigned int s:1;
        unsigned int e:8;
        unsigned int m:23;
    };
    float fl;
    int nt;
};

void uni(float f) {
    _c c;
    c.fl = f;
    printf("%x, %x, %x\n", c.s, c.e, c.m);
    printf("%08x\n", c.nt);
}

int main() {
    uint32_t i = 0;

    pf bits[] = { bits0, bits1, bits2, bits3, bits4, bits5, bits6 };

    for (int k=0; k<sizeof(bits)/sizeof(pf); ++k) {
        getTimerDelta();
        do { bits[k](i);
            // int msb;
            // asm("bsrl %1,%0; inc %0" : "=r"(msb) : "r"(i));
        } while (++i);
        printf("%d: time=%f\n", k, getTimerDelta());
    }

    uni(5.438f);
    uni(-543.8f);

    // getTimerDelta();
    // do {
    //     int msb;
    //     asm("bsrl %1,%0; inc %0" : "=r"(msb) : "r"(i));
    // } while (++i);
    // printf("Raw asm: time=%f\n", getTimerDelta());
    //
    //
    // getTimerDelta();
    // do {
    //     union {uint32_t asInt[2];double asDouble;} t;
    //     t.asDouble = (double)i; //+0.5 для коррекции
    //     return  (t.asInt[1] >> 20)-0x400+2;
    // } while (++i);
    // printf("Raw dbl: time=%f\n", getTimerDelta());

    return 0;
}
