#pragma once

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// NOTE: used here to help *understand* codeflow instead of focus on optimization
#define likely(x) __builtin_expect(!!(x), 1)
#define unlikely(x) __builtin_expect(!!(x), 0)

#define LOG_AT(stream, pfx, fmt, ...) \
    do { \
        if (fprintf(stream, (pfx "[%d]: " fmt "\n"), __LINE__, __VA_ARGS__) <= 0) { \
            abort(); \
        } \
        (void)fflush(stream); \
    } while (0)

#define LOG_INFO(...) LOG_AT(stdout, "Info", __VA_ARGS__)

#define LOG_ERR(...) LOG_AT(stderr, "Error", __VA_ARGS__)

#define LOG_FATAL(...) \
    do { \
        LOG_AT(stderr, "Fatal", __VA_ARGS__); \
        (void)fflush(NULL); \
        exit(EXIT_FAILURE); \
    } while (0)

#define LOG_FATAL_ERRNO(e, fmt, ...) LOG_FATAL(fmt "-> [" #e "=%d]: %s", __VA_ARGS__, e, strerror(e));

#define LOG_ABORT(...) \
    do { \
        LOG_AT(stderr, "Bug", __VA_ARGS__); \
        (void)fflush(NULL); \
        abort(); \
    } while (0)

#define CONCAT_INNER(a, b) a##b
#define CONCAT(a, b) CONCAT_INNER(a, b)
#define UNIQUE_NAME(nm) CONCAT(nm, __LINE__)

#define ERRNO_CALL(fn, ...) ERRNO_CALL_(UNIQUE_NAME(_ret), fn, __VA_ARGS__)
#define ERRNO_CALL_(ret, fn, ...) \
    do { \
        int const ret = (fn)(__VA_ARGS__); \
        if (unlikely(ret < 0)) { \
            if (likely(ret == -1)) { \
                LOG_FATAL_ERRNO(errno, "%s", (#fn)); \
            } \
            LOG_ABORT("undocumented ret=%d", ret); \
        } \
    } while (0)

#define POSIX_CALL(fn, ...) POSIX_CALL_(UNIQUE_NAME(_ret), fn, __VA_ARGS__)
#define POSIX_CALL_(ret, fn, ...) \
    do { \
        int const ret = (fn)(__VA_ARGS__); \
        if (unlikely(ret != 0)) { \
            LOG_FATAL_ERRNO(ret, "%s", (#fn)); \
        } \
    } while (0)

#define LOG_INFOV(pfx, cmdv) \
    do { \
        (void)fprintf(stdout, "%s", pfx); \
        for (size_t k = 0; k < sizeof(cmdv) && cmdv[k]; ++k) { \
            (void)fprintf(stdout, " %s", cmdv[k]); \
        } \
        (void)fprintf(stdout, "\n"); \
        (void)fflush(stdout); \
    } while (0)
