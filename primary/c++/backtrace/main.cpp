//usr/bin/g++ "$0" -o "${0%.*}" || exit && exec "${0%.*}"
#include <iostream>
#include <memory>
#include <execinfo.h>

std::string
get_backtrace(char const * separator = " | ")
{
    size_t const maxdepth = 100;
    void* addresses[maxdepth] = {};
    int nr = backtrace(addresses, maxdepth);
    char **frames = backtrace_symbols(addresses, nr);
    auto deallocator = std::unique_ptr<char*,void(*)(void*)>(frames, free);

    size_t const hexstrsz = 2 * sizeof(void*) + 1;
    char hexstrbuf[hexstrsz] = {};

    auto bt = "backtrace(" + std::to_string(nr) + "): ";
    for (int i = 0; i < nr; ++i) {
        if (frames) {
            bt += frames[i];
        } else {
            snprintf(hexstrbuf, hexstrsz, "%x", addresses[i]);
            bt += hexstrbuf;
        }
        if (i < nr - 1) {
            bt += separator;
        }
    }
    return bt;
}

struct runtime_error_logged : std::runtime_error
{
    explicit runtime_error_logged(char const *const msg)
        : runtime_error_logged(std::string(msg)) { }

    explicit runtime_error_logged(std::string msg)
        : std::runtime_error(std::move(msg)) {
        std::cout << "exception: " << msg << std::endl;
        std::cout << get_backtrace() << std::endl;
    }

    virtual ~runtime_error_logged() noexcept = default;

    virtual const char* what() const noexcept override {
       return std::runtime_error::what();
    }
};

int main() {
    try {
        throw runtime_error_logged("failed");
    } catch (std::runtime_error const& exc) {
        std::cout << exc.what() << std::endl;
    }
    return 0;
}
