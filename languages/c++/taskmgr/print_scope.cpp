//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 "$@"
#if __INCLUDE_LEVEL__
#pragma once
#endif

#include <cstdio>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <mutex>
#include <string>
#include <type_traits>

namespace std {

// INFO: enum -> integer -> string
template <typename T>
typename enable_if<is_enum<T>::value, string>::type
to_string(T const val)
{
    return to_string(static_cast<typename underlying_type<T>::type>(val));
}

// INFO: pointer -> hexstring (e.g. 0x1234abcd)
template <typename T>
typename enable_if<is_pointer<T>::value, string>::type
to_string(T const val)
{
    int constexpr hexstrsz = 2 + 2 * sizeof(void*) + 1;
    char hexstrbuf[hexstrsz] = {};
    int const num = snprintf(hexstrbuf, hexstrsz, "%8p", val);
    if (num < 0 || num >= hexstrsz) {
        abort();  // unlikely, never throw
    }
    return hexstrbuf;
}

}

static int g_tid = 0;
static thread_local int g_depth = 0;
static char const* const s_indent = ": ";

// WARN: don't make this function template -- thread_local is duplicated
void print(char const* const text) {
    static std::mutex s_mutex;
    std::lock_guard<std::mutex> lock(s_mutex);
    static thread_local int s_tid = g_tid++;

    std::cout << s_tid << "| ";
    for (int i = 0; i < g_depth; ++i)
        std::cout << s_indent;
    std::cout << text << std::endl << std::flush;
}

void print(std::string const& text) {
    print(text.c_str());
}

// BAD:(fnptr=null): when lambda captures other functions or members
// REF: https://stackoverflow.com/questions/18039723/c-trying-to-get-function-address-from-a-stdfunction
// template<typename Fn, typename... Args>
// void print(std::function<Fn(Args...)> const& f) {
//     typedef Fn(Fn_t)(Args...);
//     print(std::to_string(f.template target<Fn_t*>()));
// }

template <typename T>
void print(T value) {
    print(std::to_string(value));
}

struct print_scope {
    int m_tid;
    char const* const m_text;

    print_scope(char const* const text) : m_text(text) {
        print(m_text);
        ++g_depth;
    }
    ~print_scope() {
        --g_depth;
        print((std::string("~") + m_text).c_str());
    }
};

// ALT: use global __COUNTER__
#define TRACE_SCOPE(name) print_scope const log##__LINE__(name);
#define TRACE_FUNC() TRACE_SCOPE(__FUNCTION__)
// #define TRACE_FUNC(...) TRACE_SCOPE(__FUNCTION__, __VA_ARGS__)

// Global Static Object
//  - created first inside _start() before main()
//  - dectructed last of all after main() and local _atexit() (order-dependent)
static print_scope const firstGSO(".init_array");

#if !__INCLUDE_LEVEL__
int main() {
    TRACE_FUNC();

    if (std::atexit([] { print("atexit"); })) {
        exit(EXIT_FAILURE);
    }

    { TRACE_SCOPE("inner"); }

    return EXIT_SUCCESS;
}
#endif
