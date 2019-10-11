//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS="-std=c++11 -g" LDFLAGS=-lpthread "$@"
#if __INCLUDE_LEVEL__
#pragma once
#endif

// TODO: need env var to only rebuild binary without launching
//   BAD: binary implicitly depends on tree of headers
// MAYBE: gather embedded make recipes which use generated gcc header deps before compiling

#include "async_queue.cpp"
#include "print_scope.cpp"

#include <atomic>
#include <cassert>
#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <mutex>
#include <pthread.h>
#include <queue>
#include <string>
#include <sys/types.h>
#include <thread>

// FIXED:(glibc<2.30): no native gettid()
#include <sys/syscall.h>
#include <unistd.h>
#ifndef gettid
#define gettid() syscall(SYS_gettid)
#endif

// REF: how to write your own task managers
//   https://www.youtube.com/watch?v=QIHy8pXbneI&feature=youtu.be
//
// TODO:(asynq): use ref pointing to same queue to create Pool
//  => notify_one() will pass tasks one-by-one to each worker in round robin manner
//  => Pool with single worker is single processing unit
//  => Group is applied to Pool and not directly to Workers
//
// ARCH:(FSM): initialization -> working -> shutdown(_now) -> destruction
//
// IDEA: create guard as last object after topology ::
//   E.G. A a; TaskRunningGuard g = wkr.start(); ...; ~g(); ~a();
//   FAIL: dtor of any object created after guard will be called earlier than guard
//   BET? dedicated function "wait_finished()" -- all destructors will be strictly after that
//
// IDEA: wait all tasks normally finished in queue.dtor()
//   FAIL: on exception it may take too long
//   BET? on shutdown always cancel tasks ASAP
//
// IDEA: each object must wait until its refs released by worker
//   NEED: special inner data structures
//     - annotate each task by address of "this" for group matching
//     - track refcount for each address and notify when it becomes zero
//   E.G. ~obj(){ m_wkr.wait_all_done_for(this); }
//   ALT: individual WorkerWrapper(&) per each object, which will wait automatically in dtor
//   NICE: can post additional tasks in dtor when necessary
//   FAIL: too complex picture of destruction -- you never know who and where will be released
//
// IDEA: directed dispatcher can be destroyed before stopping worker (thread with main loop of some library)
//   FAIL: too fragile -- no way to ensure dispatcher is "pure" and don't post tasks with self-ref into worker
//   WARN: despite dispatcher created after worker, you must release refs before worker shutdowns or dispatcher itself
//   destroys E.G. Wkr wkr; Dbus dbus(wkr); wkr.wait_finished(); dbus.stop(); wkr.stop(); ~dbus(); ~wkr();
//
// THINK: how to be with Worker ref passed into another thread ?
//   <!! we must stop worker before objects in that thread start destruction
//

class Worker;
using WorkerRefs = std::vector<std::reference_wrapper<Worker>>;
using CancelPred = std::function<bool()>;
using Task = std::function<void(CancelPred)>;  // = cancellable lambda rvalue
using AsyncQueue = async_queue<Task>;

// NOTE: when "switching" underlying data
// DEV: must discard wrong tasks when executing based on some identifier
//   <= mitigates incurable concurrency due to delays in old events delivery (i.e. different identifier)
enum class PolicyNewTask : uint8_t {
    ALLOW,      // accumulate tasks meanwhile and resume execution after switch
    IGNORE,     // discard all tasks for time being
    LOGIGNORE,  // only print WARN log and then ignore
    THROW,      // throws exception when trying to post (must beforehand broadcast and stop everything)
    WAIT,       // blocked on post-local mutex until wait_complete completes
};

enum class TaskPriority : uint8_t {
    NORM,  // back
    HIGH,  // front
};

class Worker : print_scope
{
private:
    AsyncQueue& m_asyncq;
    std::string m_name;
    std::mutex m_mutex;
    std::condition_variable m_completed;  // RENAME? m_taskend
    std::atomic<PolicyNewTask> m_policy{PolicyNewTask::ALLOW};
    std::atomic_bool m_executing{};
    std::atomic_bool m_canceled{};
    std::atomic_bool m_stopped{};
    std::atomic_bool m_shutdown{};
    std::thread::id m_tid{};

    // WARN! "thread" must be created very last
    //   * it immediately executes .run() on incomplete "this"
    //   * must be destructed first: throw if not joinable before other members dtors to prevent use-after-free
    std::thread m_thread;

private:
    using lock_t = std::unique_lock<std::mutex>;
    using guard_t = std::lock_guard<std::mutex>;

    static std::mutex s_mutex;
    static WorkerRefs s_initialized;

public:
    WorkerRefs Initialized() {
        guard_t _guard(s_mutex);
        // NOTE:(under mutex): return immediate copy of all refs to prevent inconsistent container
        // FAIL: will break if you start deleting refs in Worker dtor
        return WorkerRefs(s_initialized);
    }

public:
    // NOTE: immediately ready to process tasks after constructing
    Worker(AsyncQueue& asyncq, std::string const& name)
        : print_scope(__FUNCTION__), m_asyncq(asyncq), m_name(name), m_thread(std::bind(&Worker::run, this)) {
        m_tid = m_thread.get_id();
        if (m_name.empty()) {
            // [_] CHECK: if "pthread_setname_np" will return error or not on empy string -- to remove this check completely
            throw std::logic_error("Err: empty name");
        }
        int const rc = pthread_setname_np(m_thread.native_handle(), m_name.c_str());
        if (rc) {
            if (rc == ERANGE) {
                throw std::logic_error("Err: thread name length must be 15 chars or less");
            } else {
                print("Err: failed to set name=" + name
                        + " for thread tid=" + std::to_string(static_cast<int>(gettid())));
            }
        }
        guard_t _guard(s_mutex);
        s_initialized.push_back(*this);
    }

    ~Worker() {
        // BUT:BAD: we can't clear() policy in any of {emit,wait}_shutdown if called from mutliple threads
        //
        // if (!m_asyncq.empty()) {
        //     // NOTE: it's expected you will exit with correct method which
        //     // clears rest of queue for you and releases closured refs to resources
        //     switch (m_policy) {
        //         using E = PolicyNewTask;
        //     case E::ALLOW: break;
        //     case E::IGNORE: break;
        //     case E::LOGIGNORE: print(static_cast<void*>(&task)); break;
        //     case E::THROW: abort();
        //     default: throw std::logic_error("Err: unsupported shutdown policy enum"); ;
        //     }
        // }

        // CONTRACT: thread must not be joinable in dtor -- you must call blocking wait_shutdown() somewhere
    }

private:  /// implementation policy
    // TODO: rename to { start, init, listen } -- so first line of logs had more sense
    void run() {
        TRACE_FUNC();
        // BUG: blocks again after emit_shutdown() and cancelling last task
        //   i.e. you MUST post empty task to really cancel
        //   OR:BET:RFC: while(!m_shutdown) { pop }
        // while (auto task = m_asyncq.pop(m_shutdown, m_executing))

        while (!m_shutdown) {
            // TRY: reuse "task" object itself as m_executing
            auto task = m_asyncq.pop(m_shutdown, m_executing);
            if (!task) {
                break;
            }
            // FAIL? racing if task is popped but not executed yet
            //   => wait_cancel() immediately returns
            // std::lock_guard<std::mutex> _lock(m_executing);
            exec(std::move(task));
            // NOTE:(m_executing): ensure there are no racing gaps between "pop_wait" and "cancel"
            lock_t const _lock(m_mutex);
            m_executing = false;
            m_completed.notify_all();  // -> unblock "cancel", try unblock "wait_all_done"
        }
    }

    void exec(Task&& task) const {
        TRACE_FUNC();
        if (!task) {
            throw std::invalid_argument("Err: undef task");
        }

        // NOTE: always reset :: { empty queue -> emit_cancel -> post -> exec } must not cancel future tasks
        m_canceled = false;

        // ARCH: "try..catch" itself is part of execution *policy* -- override when necessary
        try {
            TRACE_SCOPE(m_name);
            // MAYBE: replace passing isCancelled() through last arg by inheriting all Tasks from common class with isCancelled() base method ?
            //   BAD: won't help with passing control from task wrapper to outside agnostic classes
            //   BAD: hides cancellation interface, without explicit belonging to API like it is with last arg
            //   BAD? you must fully contain your business logic inside SmthTask classes -- so isCancelled() will be available anywhere
            //     ?? BUT: is it good or bad -- merge "Task" containerism with business logic ??
            auto isCancelled = [this]() -> bool { return m_canceled; };
            task(std::move(isCancelled));
        } catch (std::exception const& exc) {
            print("Err: " + m_name + " exception :: " + exc.what());
        } catch (...) {
            print("Err: " + m_name + " exception :: unknown");
        }
    }

public:  /// low-level interfaces
    // Change default action applied to all tasks when posting
    void set_policy(PolicyNewTask const policy) {
        TRACE_FUNC();
        m_policy = policy;
    }

    // Stop/resume execution loop (active task is not affected)
    void pause_loop(bool const paused) {
        TRACE_FUNC();
        m_asyncq.block(paused);
    }

    // Remove all pending tasks (active task is not affected)
    void clear_queue() {
        TRACE_FUNC();
        // MAYBE: don't need these checks and simply allow clearing multiple times even when thread already joined ?
        //   BUT: contract... <VS> incurable racings in transport...
        // if (m_shutdown) {
        //     throw std::logic_error("Err: usage contract");
        // }
        m_asyncq.clear();
    }

    // Separate async function to allow canceling itself
    // BAD:(locality): can't restore "m_canceled" in scope of same function
    // ALT: merge into single interface :: cancel_wait(bool const wait = true)
    void emit_cancel() {
        TRACE_FUNC();
        // ARCH:(if (m_executing) m_canceled=true): must not modify "m_canceled" when waiting on empty queue
        //   INFO generally it isn't bad because has no effect on codeflow
        //   BUT:(otherwise): we will have a "gap=[pop...exec]" when state may be inconsistent with expectations
        //   BUT:ALSO: we still have a "gap" after task execution when state may become inconsistent anyway...

        // THINK: when "pause(true)" and there are no active task -- must "cancel" affect next popped task or not ?
        // NOTE: no sense to notify anything -- run() will notify by itself when tasks will exist
        m_canceled = true;
    }

    // RENAME: wait_running_task()
    // ALT:BAD:(naming): "wait_cancel" will wait even non-canceled active running task
    // WARN!(deadlock): if two workers wait for each other (or one waits for itself)
    void wait_running_task() {
        TRACE_FUNC();
        if (std::this_thread::get_id() == m_tid) {
            throw std::logic_error("deadlock: task waits for finishing of its own cancel");
        }
        lock_t _lock(m_mutex);
        // BAD:(usage): will result in imm unblock even if active task wasn't canceled
        // m_completed.wait(_lock, [this] { return (m_shutdown || !m_canceled); });
        // BAD:(racing): has "racing gap" between m_canceled=false after task exec and atomic emit_cancel()
        // m_completed.wait(_lock, [this] { return (!m_canceled && !m_executing); });
        m_completed.wait(_lock, [this] { return !m_executing; });
    }

    // VIZ: possible shutdown variations
    //  * shutdown() -- imm async op -- waits until active task completes
    //  * shutdown_now() -- imme async op -- cancels active task
    //  * post_shutdown() -- imm async op -- adds "end" task after last pending task; can be canceled
    //  * wait_shutdown() -- blk sync op -- waits until queue is totally empty (can be appended anytime)
    //  * post_wait_shutdown() -- blk sync op -- only waits until present tasks completed, ignores new
    // THINK: how to ensure all business logic completes before we emit post_shutdown() ?
    void emit_shutdown(PolicyNewTask const shutdown_policy) {
        TRACE_FUNC();
        // [_] TODO: when initiating postponed shutdown, you must leave main loop
        // only *after* all current tasks finished, not before
        m_shutdown = true;
        pause_loop(true);


        // ALG: user must supply policy from outside -- IGNORE or THROW
        // WARN: very hard to eliminate racing with other threads posting to your shutting down queue
        //   => to use THROW you must broadcast forthcoming shutdown and wait refs release confirmation from everybody
        set_policy(shutdown_policy);
        emit_cancel();
    }

    // IDEA: must throw on shutdown -- detect anybody uses worker after shutdown initiated
    //   <= we expect the signal was sent to everyone before worker's shutdown was initiated
    // FAIL? user which called post() but preempted before mutex will
    // generate exception when trying to add new task after waking up
    //   THINK? can we prevent this exception at all or process it correctly
    //   BAD: nothing we can do with this sleeping gap
    // MAYBE: allow to always add/ignore and clear() rest of queue on shutdown
    //   OR:BET: at bottom of wait_until_finish()
    // WARN: you may "ignore" or "throw" because some object will still try
    //   to post something until their dtor called
    //   BUT: never "allow" to prevent capturing refs to soon-to-be-destroyed objects
    void wait_shutdown() {
        TRACE_FUNC();
        // FAIL:(racing): can't wait shutdown on join
        //   MAYBE: provide condvar to notify waiting on shutdown ?
        //     BET: wait on same but with additional condition
        //       m_completed.wait(_lock, [this] { return (m_shutdown && !m_executing && m_asyncq.empty()); });
        //     BAD: will wake up after each task -- much more often than necessary
        //   MAYBE: it can be the same condvar as m_completed -- but only when queue is stopped and empty
        //     BUT: must explicitly clear queue in this case
        // FAIL:(deadlock): can't pop next task
        // lock_t const _lock(m_mutex);

        // WARN: must noop when multiple threads are calling
        if (m_thread.joinable()) {
            // NOTE: release cyclic refs to resources (must become unavailable before their dtors)
            // BUG: removes "planned_shutdown" when called before join
            // clear_queue();

            // BAD: ignores <Ctrl-C> when blocked
            m_thread.join();
            clear_queue();
        }
    }

public:  /// aggregated interfaces
    // THINK: can you prevent business logic from posting new tasks ?
    //   e.g. some library with inner event loop, which uses post() as callback
    //     => you must add there ignore condition anyway (max: you can log skipped tasks)
    // ALT: pair of symmetrical function :: accept_new()

    // Drop all tasks and stop processing
    // NOTE: we don't need clear_start() because ignore_new(true) will guarantee empty container
    void stop_now() {
        // MAYBE: unite "ignoreNew" and "canceled" flags
        //  ? do we need "cancel current" but still allow adding more tasks meanwhile ?
        //    => then we will must press "cancel" multiple times to cancel all
        //  ? do we need "ignore new" but continue processing current tasks ?
        //    => maybe useful for safe complete shutdown...
        set_policy(PolicyNewTask::IGNORE);
        pause_loop(false);
        clear_queue();
        cancel();
    }

    // Wait all pending tasks had executed and stop processing
    void stop_when_done() {
        set_policy(PolicyNewTask::IGNORE);
        wait_completion();
    }

    // Restore normal processing
    void resume() {
        set_policy(PolicyNewTask::ALLOW);
        // TODO: flip m_stopped flag
        //   false -- pull task by queue.get(), block if empty
        //   true -- always block even before queue.get()
        pause_loop(false);
    }

    void reset() {
        stop_now();
        resume();
    }

    // BET: provide Task.cancel() method and bind it to queue when popping task
    //   => different meaning when cancelling whole queue or single task
    void cancel() {
        emit_cancel();
        wait_running_task();
    }

    // End of processing (unrecoverable)
    // WARN: you must never call post() after shutdown()
    void shutdown() {
        emit_shutdown(PolicyNewTask::THROW);
        wait_shutdown();
    }

    // RENAME: wait_empty(), wait_exhauted(), wait_done(), BET: wait_idle()
    // ALG: exec everything in queue VS exec everything which was present in the moment of function call
    //   <= may combine two strategies above with PolicyNewTask
    // WARN: after emit_shutdown() it must continue waiting until all tasks are canceled -- don't exit immediately by
    // m_shutdown
    void wait_completion() {
        // ATT: don't ignore_new() and don't cancel()
        //  => you only expect singular point when queue is empty and no running task present
        // THINK: how to be with stopped non-empty queue ?

        if (std::this_thread::get_id() == m_tid) {
            throw std::logic_error("deadlock: task waits for finish of itself");
        }

        // THINK: prevent new post() by access mutex OR allow append new tasks when waiting ?
        //   MAYBE: two different api ?
        // ALT:NEED: special api in asyncq.wait_until_empty()

        // FAIL: how to be with racing between .pop() task and .exec() ?
        // std::lock_guard<std::mutex> _lock(m_executing);

        lock_t _lock(m_mutex);

        // INFO: mutex is temporarily released, when sleeping on condvar, and reacquired after resuming
        // NOTE: explicitly use "ignoreNew(true)" to wait only for currently present tasks
        // [_] DEV: use wait_for() to be able to issue multiple interrupts to DB
        //   i.e. { emit_cancel(); while (!wait_completion(0.5sec)) sqlite3_interrupt(); }
        //   OR: directly use blocking cancel :: while (!cancel(0.5sec)) sqlite3_interrupt();
        m_completed.wait(_lock, [this] { return (!m_executing && m_asyncq.empty()); });
    }

    // WARN: creates temporary cyclic dependency on resources until task is completed
    //   <= capturing "this" into lambda results in conflicting lifespan inversion
    // TODO: return taskid (e.g. address of task) to be able to wait on it
    //   ALT:BAD? use promise-future ?
    //   NEED: scan queue to detect if taskid was cancelled
    //     MAYBE: use monotonically increasing numbers and lower/upper boundary
    //     BAD: can cancel task in the middle
    //   BET? directly return wrapped task itself -- to access .cancel(), .isCancelled(), and others
    void post(Task&& task, bool const supplant = false) {
        TRACE_FUNC();
        std::lock_guard<std::mutex> _lock(m_mutex);
        switch (m_policy) {
            using E = PolicyNewTask;
        case E::ALLOW: break;
        case E::IGNORE: return;
        case E::LOGIGNORE: print(static_cast<void*>(&task)); return;
        case E::THROW: throw std::logic_error("Err: adding tasks is prohibited");
        case E::WAIT: /* std::lock_guard<std::mutex> _lock(m_finishing); */ break;
        default: throw std::logic_error("Err: unknown enum"); ;
        }
        if (supplant) {
            // WARN: posting is always async to return as fast as possible and prevent blocking in dispatchers
            //   BAD: active task in the process of cancelling *may* post new tasks into same queue
            //   i.e. after post() you will have queue={ PostedFromCancelling, ThisNewTask, CancellingActiveTask }
            emit_cancel();
            clear_queue();
        }
        m_asyncq.push(std::move(task));
    }

    // Drop active and pending tasks and immediately execute new one
    void clear_post(Task&& task) {
        post(std::move(task), true);
    }

    void wait_task(int const taskid) {
        TRACE_FUNC();
        // TODO: prevent waiting for next tasks in same queue
        if (std::this_thread::get_id() == m_tid) {
            throw std::logic_error("deadlock: task waits for finishing of its own cancel");
        }
        // DEV: scan queue periodically and wait until task popped and executed
    }

    // RENAME: cancellable_shutdown, scheduled_shutdown
    // RFC? can be replaced by ignoreNew + wait_completion
    void planned_shutdown() {
        TRACE_FUNC();
        // std::lock_guard<std::mutex> _lock(m_mutex);
        // MAYBE:BET: don't ignore current ongoing tasks -- OR: cancel all of them explicitly
        // WARN! cancel() called from another thread may remove posted exit() task
        m_asyncq.push([this](CancelPred const isCancelled) { emit_shutdown(PolicyNewTask::THROW); });

        // NOTE: last activity ever
        // FAIL: racing between reset() and post_shutdown()
        //   i.e. reset() may cancel post_shutdown()
        // FAIL: racing between if(m_shutdown) ... and actual post().push()
        //   => ALT: ignore all tasks after this one
        // m_asyncq.clear_push(decltype(m_asyncq)::end);
    }

    // RENAME: wait_finished(), wait_until_finish()
    void wait_shutdown_finished() {
        // BUT! other threads may still try add new tasks when current thread shutdowns worker
        set_policy(PolicyNewTask::THROW);
        wait_completion();
        // ALT: clear();
    }
};

std::mutex Worker::s_mutex{};
WorkerRefs Worker::s_initialized{};

#if !__INCLUDE_LEVEL__
int main() {
    TRACE_FUNC();

    int counter = 0;
    auto const idle = [&](int t) {
        TRACE_FUNC();
        std::this_thread::sleep_for(std::chrono::milliseconds(t));
        print(++counter);
    };

    // ARCH: build static topology with ordered lifetimes
    AsyncQueue asyncq;
    Worker wkr(asyncq, "W1");

    // NOTE: emulate some activity caused by external clients
    // NOTE: creates temp cyclic dep :: NEVER destroy User() before Worker()
    wkr.post([&](CancelPred const isCancelled) { idle(500); });
    wkr.post([&](CancelPred const isCancelled) { idle(800); });
    // wkr.post([&](CancelPred const isCancelled) { while (!isCancelled()) idle(100); });
    wkr.planned_shutdown();

    // ARCH:
    //  - block main thread -- no need for looping e.g. while(true)sleep
    //  - wait all cyclic refs are released before dtor() of grabbed resources
    wkr.wait_shutdown();

    return EXIT_SUCCESS;
}
#endif
