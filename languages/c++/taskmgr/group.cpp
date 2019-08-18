//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lpthread "$@"
#if __INCLUDE_LEVEL__
#pragma once
#endif

#include "worker.cpp"

// DEV:(Bundle): use pair<enum id, char name> -- and supply enums into methods to access
// #include <boost/container/flat_map.hpp>
// char const* const g_WorkerNames[] = { "W1_COMMANDS", "W2_DOWNLOAD", };
// class Pool { boost::container::flat_map<std::string, QWorker> m_workers; };

// NOTE: direct loop has too big latency :: for (auto& w : m_workers) w.get().cancel();
// BET:PERF: wait everything at once in single condvar callback passed through arguments to each cancel()
//   i.e. condvar.wait([] { for (auto& w : m_workers) if (w.is_executing()) return 0; return 1; });


class User : print_scope
{
private:
    QWorker& m_Worker;
    int m_counter = 0;

public:
    User(QWorker& wkr) : print_scope(__FUNCTION__), m_Worker(wkr) {}
    ~User() {}

    void action(int t) {
        TRACE_FUNC();
        std::this_thread::sleep_for(std::chrono::milliseconds(t));
        print(++m_counter);
    }
    void dispatch_events() {
        TRACE_FUNC();
        // NOTE: creates temp cyclic dep :: NEVER destroy User() before QWorker()
        m_Worker.post([this] { action(500); });
        m_Worker.post([this] { action(800); });
        m_Worker.post([this] { m_Worker.post_shutdown(); });
    }
};

#if !__INCLUDE_LEVEL__
int main() {
    TRACE_FUNC();

    if (std::atexit([] { print("atexit"); })) {
        return EXIT_FAILURE;
    }

    // ARCH: build static topology with ordered lifetimes
    QWorker wkr("W1");
    User user(wkr);

    // NOTE: emulate some activity caused by external clients
    user.dispatch_events();

    // ARCH:
    //  - block main thread -- no need for looping e.g. while(true)sleep
    //  - wait all cyclic refs are released before dtor() of grabbed resources
    wkr.wait_shutdown();

    return EXIT_SUCCESS;
}
#endif
