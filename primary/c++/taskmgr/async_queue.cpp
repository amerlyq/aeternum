//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS=-lpthread "$@"
#if __INCLUDE_LEVEL__
#pragma once
#endif

#include "print_scope.cpp"

#include <atomic>
#include <condition_variable>
#include <initializer_list>
#include <mutex>
#include <queue>

template <typename T>
class async_queue
{
public:
    using lock_t = std::unique_lock<std::mutex>;

    // HACK: reuse default value as exit condition
    //   e.g. std::function<void()>()
    // WARN: must be convertible to bool "false"
    static T const end;

private:
    // ALT:USE: boost::heap::priority_queue<T, boost::heap::stable<true>> m_queue;
    std::queue<T> m_queue;
    mutable std::mutex m_mutex;
    std::condition_variable m_nonempty;  // ALT:(rename): m_pending
    std::atomic_bool m_blocked{false};

public:
    async_queue() = default;
    async_queue(std::initializer_list<T> args) : m_queue(std::move(args)) {}

    void push(T&& value, bool const clearothers = false) {
        TRACE_FUNC();
        lock_t _lock(m_mutex);
        if (clearothers) {
            // NOTE: cancel strictly before "clear" -- active task may post something again
            // cancel(_lock);
            decltype(m_queue) tmp;
            m_queue.swap(tmp);
        }
        m_queue.push(std::move(value));
        // NOTE: ensure "this" won't be destroyed before function fully exits (asynchronous signal)
        // REF:(pessimization): https://en.cppreference.com/w/cpp/thread/condition_variable/notify_one
        m_nonempty.notify_one();  // -> new pending task for .pop_wait()
    }

    void clear_push(T&& value) {
        push(std::move(value), true);
    }

    void block(bool const blocked) {
        TRACE_FUNC();
        m_blocked = blocked;
        lock_t const _lock(m_mutex);
        m_nonempty.notify_one();  // -> resume looping on .pop_wait()
    }

    // ALT:(rename): pop_wait()
    T pop(std::atomic_bool const& stopped, std::atomic_bool& extracted) {
        TRACE_FUNC();
        lock_t _lock(m_mutex);

        {
            TRACE_SCOPE("wait");
            // INFO: mutex is temporarily released, when sleeping on condvar, and reacquired after resuming
            m_nonempty.wait(_lock, [this, &stopped] {
                print("***wake_up***");
                return (stopped || !(m_blocked || m_queue.empty()));
            });
        }

        if (stopped) {
            return async_queue::end;
        }

        // TRY: reuse existence of returned "value" itself as "m_executing" flag
        extracted = true;
        T value = std::move(m_queue.front());
        m_queue.pop();
        print(m_queue.size());
        return value;
    }

    void clear() {
        TRACE_FUNC();
        lock_t const _lock(m_mutex);
        decltype(m_queue) tmp;
        m_queue.swap(tmp);
    }

    bool empty() const {
        TRACE_FUNC();
        lock_t const _lock(m_mutex);
        return m_queue.empty();
    }
};

template <typename T>
T const async_queue<T>::end{};


#if !__INCLUDE_LEVEL__
int main() {
    TRACE_FUNC();

    std::atomic_bool shutdown{false};

    // FIXME: must use constref to singleton value
    auto end = async_queue<int>::end;
    async_queue<int> q = {1, 2, 3, 4, end};

    // while ((auto v = q.pop(shutdown)) != end) {
    while (auto v = q.pop(shutdown)) {
        print(v);
        if (v == 3)
            shutdown = true;
    }

    return EXIT_SUCCESS;
}
#endif
