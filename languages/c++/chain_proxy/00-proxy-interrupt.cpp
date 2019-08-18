//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/env -i -- PATH=/bin CXXFLAGS='-g -std=c++11' LDFLAGS='-lpthread' \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
#include <atomic>
#include <chrono>
#include <iostream>
#include <memory>
#include <mutex>
#include <thread>

#include <stdexcept>
struct Cancelled : std::logic_error {
  using std::logic_error::logic_error;
};


struct MyDB {
    MyDB(char id) : m_id(id), m_ongoing(ATOMIC_FLAG_INIT) {}
    void interrupt() const {
        m_ongoing.clear();  // ALT: sqlite3_interrupt();
    }
    void exec() const {
        if (m_ongoing.test_and_set()) {
            throw std::logic_error("BUG: already being executed");
        }
        std::cout << "MyDB(" << m_id << ") beg...";
        for (int i = 0; i < 10; ++i) {
            if (!m_ongoing.test_and_set()) {
                m_ongoing.clear();
                std::cout << std::endl;
                throw Cancelled("interrupted");
            }
            std::cout << m_id << std::flush;
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
        std::cout << " END(" << m_id << ")" << std::endl;
    }
    char const m_id;
    mutable std::atomic_flag m_ongoing;
};

struct Lockable {
    using lock_t = std::unique_lock<std::mutex>;
    Lockable(MyDB const *db, lock_t lock) : m_db(db), m_lock(std::move(lock)) {
        std::cout << "*lock*" << std::endl;
    }
    ~Lockable() { std::cout << "*unlock*" << std::endl; }

    explicit Lockable(Lockable const&) = delete;
    Lockable& operator=(Lockable const&) = delete;
    Lockable(Lockable&&) = default;
    Lockable& operator=(Lockable&&) = default;

    MyDB const * operator->() const { return m_db; }

    lock_t m_lock;
    MyDB const * const m_db;
};

struct Proxy {
    Proxy() = default;
    void use(std::unique_ptr<MyDB> db) {
        // FAIL: must be under mutex, but can't be under mutex...
        if (m_db) {
            m_db->interrupt();
        }
        std::lock_guard<std::mutex> guard(m_Mutex);
        // NOTE: interrupt and destroy whole pool of connections
        m_db = std::move(db);
    }
    Lockable operator->() const {
        // BET:(<C++14): use RW/S boost::shared_lock + boost::unique_lock
        Lockable::lock_t locked(m_Mutex);
        std::cout << "Proxy->" << std::endl;
        if (!m_db) {
            throw std::logic_error("BUG: accessing empty proxy");
        }
        return Lockable(m_db.get(), std::move(locked));
    }
    std::unique_ptr<MyDB> m_db;
    mutable std::mutex m_Mutex;
};

void processdata(Proxy const& proxy, std::atomic_bool& ready_to_process) {
    // simulate long work (processing data stream in chunks)
    while (ready_to_process) {
        std::cout << "(new data chunk)" << std::endl;
        proxy->exec();
        // simulate intermediate workload
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
        // ATT: must check interrupted state in each checkpoint
        if (!ready_to_process) {
            throw Cancelled("cancelled");
        }
        proxy->exec();
        // simulate cleanup workload
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
        // ATT: discard evaluation results of thread even in this case
        if (!ready_to_process) {
            throw Cancelled("cancelled");
        }
    }
}

int main()
{
    Proxy proxy;
    std::atomic_bool ready_to_process(false);

    // activate some db
    proxy.use(std::unique_ptr<MyDB>(new MyDB('A')));
    ready_to_process.store(true);

    std::thread task([&](){
        // simulate continuous dispatching of different requests (transport)
        for (int i = 0; i < 2; ++i) {
            // wait until any db becomes active
            while (!ready_to_process) {
                std::this_thread::sleep_for(std::chrono::milliseconds(200));
            }
            try {
                // dispatch transport request to worker
                processdata(proxy, ready_to_process);
            } catch (Cancelled const& exc) {
                // notify transport about cancelled task
                std::cout << exc.what() << std::endl;
            }
        }
    });

    // NOTE: depending on timing ongoing tasks will be cancelled or interrupted
    int dt = 700;   // interrupts in A
    // int dt = 1100;  // cancels before B
    std::this_thread::sleep_for(std::chrono::milliseconds(dt));

    // ATT: must send and process "db switch" signal to task (emulated by atomic flag)
    ready_to_process.store(false);

    proxy.use(std::unique_ptr<MyDB>(new MyDB('B')));
    ready_to_process = true;

    // ATT: throws "already being executed" if ever executed from another thread
    // proxy->exec();

    std::this_thread::sleep_for(std::chrono::milliseconds(400));

    // NOTE: send "db switch" signal to task (emulated by atomic flag)
    ready_to_process.store(false);

    // ATT: throws "empty proxy" if thread ignored switching (try to access db again)
    proxy.use(std::unique_ptr<MyDB>());

    // ATT: throws "empty proxy"
    // proxy->exec();

    task.join();

    return 0;
}
