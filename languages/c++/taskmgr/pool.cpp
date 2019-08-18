//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS="-std=c++11 -g" LDFLAGS=-lpthread "$@"
#if __INCLUDE_LEVEL__
#pragma once
#endif

#include "async_queue.cpp"
#include "print_scope.cpp"
#include "worker.cpp"

#include <vector>

class Pool : print_scope
{
private:
    AsyncQueue m_asyncq;
    std::vector<Worker> m_workers;

public:
    static auto default_workers = std::max(1, std::thread::hardware_concurrency());

    Pool(std::string const& name, int const number = default_workers)
        : print_scope(__FUNCTION__) {
        for (int i = 0; i < number; ++i) {
            m_workers.emplace_back(m_asyncq, name + "_" + std::to_string(i));
        }
    }
};

#if !__INCLUDE_LEVEL__
int main() {
    TRACE_FUNC();

    int counter = 0;
    auto const idle = [&](int t) {
        TRACE_FUNC();
        std::this_thread::sleep_for(std::chrono::milliseconds(t));
        print(++counter);
    };

    Pool pool("W");

    // NOTE: emulate some activity caused by external clients
    // NOTE: creates temp cyclic dep :: NEVER destroy User() before Worker()
    pool.post([&](CancelPred const isCancelled) { idle(500); });
    pool.post([&](CancelPred const isCancelled) { idle(800); });
    // pool.post([&](CancelPred const isCancelled) { while (!isCancelled()) idle(100); });
    pool.planned_shutdown();

    // ARCH:
    //  - block main thread -- no need for looping e.g. while(true)sleep
    //  - wait all cyclic refs are released before dtor() of grabbed resources
    pool.wait_shutdown();

    return EXIT_SUCCESS;
}
#endif
