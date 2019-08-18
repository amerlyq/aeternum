//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-g LDFLAGS=-lpthread "$@"
#include <atomic>
#include <cassert>
#include <chrono>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <mutex>
#include <thread>
#include <vector>

struct IDB {
    virtual void exec() const = 0;
    virtual void interrupt() const = 0;
};

struct MyDB : IDB {
    MyDB(char id) : m_id(id) {}
    void interrupt() const override final {
        std::cout << "---Interrupt---" << std::endl;
        // ALT: sqlite3_interrupt();
        m_ongoing.clear();
    }
    void exec() const override final {
        if (m_ongoing.test_and_set()) {
            throw std::logic_error("BUG: already being executed");
        }
        std::cout << "MyDB(" << m_id << ") beg...";
        for (int i = 0; i < 20; ++i) {
            if (!m_ongoing.test_and_set()) {
                m_ongoing.clear();
                std::cout << std::endl;
                throw std::runtime_error("interrupted");
            }
            std::cout << m_id << std::flush;
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
        std::cout << " END(" << m_id << ")" << std::endl;
    }
    char m_id;
    mutable std::atomic_flag m_ongoing;
};

struct Lockable;

struct Accessor {
    virtual ~Accessor() = default;
    virtual void interrupt() const = 0;
    virtual Lockable operator->() const = 0;
    virtual explicit operator IDB const * () const {
        throw std::domain_error("not implemented");
    }
    virtual bool try_lock() const {
        throw std::domain_error("not implemented");
    }
};

// ATT: can't be replaced by std::unique_ptr<db, custom_deleter>
//  <= otherwise to call ptr->exec() you must reimplement whole IDB for all accessors
struct Lockable {
    using lock_t = std::unique_lock<std::mutex>;
    Lockable(Accessor const * const a, lock_t lock = lock_t())
    : m_a(a), m_lock(std::move(lock)) {
        assert(a);
        std::cout << "*lock*" << std::endl;
    }
    ~Lockable() { std::cout << "*unlock*" << std::endl; }

    explicit Lockable(Lockable const&) = delete;
    Lockable& operator=(Lockable const&) = delete;
    Lockable(Lockable&&) = default;
    Lockable& operator=(Lockable&&) = default;

    IDB const * operator->() {
        std::cout << "Lockable->" << std::endl;
        assert(m_a);
        return static_cast<IDB const *>(*m_a);
    }
    lock_t m_lock;
    Accessor const * const m_a;
};

struct Unsafe : Accessor {
    Unsafe(std::unique_ptr<IDB> db) : m_db(std::move(db)) {}
    virtual ~Unsafe() = default;
    Lockable operator->() const override final {
        std::cout << "Unsafe->" << std::endl;
        return Lockable(this);
    }
    void interrupt() const override final {
        m_db->interrupt();
    }
    explicit operator IDB const * () const override final {
        return m_db.get();
    }
    std::unique_ptr<IDB> const m_db;
};

struct Exclusive : Accessor {
    Exclusive(std::unique_ptr<Accessor> a) : m_a(std::move(a)) {}
    virtual ~Exclusive() = default;
    bool try_lock() const override final {
        if (m_Lock) {
            throw std::logic_error("BUG: already pre-locked");
        }
        // ATT: raises std::system_error() if already owned by this THREAD
        m_Lock = Lockable::lock_t(m_Mutex, std::try_to_lock);
        return m_Lock.owns_lock();
    }
    void interrupt() const override final {
        m_a->interrupt();
    }
    Lockable operator->() const override final {
        std::cout << "Exclusive->" << std::endl;
        if (!m_Lock && !try_lock()) {
            throw std::logic_error("BUG: simultaneous access is forbidden");
        }
        return Lockable(m_a.get(), std::move(m_Lock));
    }
    std::unique_ptr<Accessor> const m_a;
    mutable std::mutex m_Mutex;
    mutable Lockable::lock_t m_Lock;
};

struct Pool : Accessor {
    using make_new_t = std::function<std::unique_ptr<Accessor>(void)>;
    Pool(make_new_t f) : m_f(std::move(f)) {}
    virtual ~Pool() { clear(); }
    void interrupt() const override final {
        std::lock_guard<std::mutex> guard(m_Mutex);
        for (auto const& a : m_as) {
            a->interrupt();
        }
    }
    Lockable operator->() const override final {
        // FAIL: won't save us, if we are blocked after somebody called dtor()
        std::lock_guard<std::mutex> guard(m_Mutex);
        std::cout << "Pool->" << std::endl;
        for (auto const& a : m_as) {
            if (a->try_lock()) {
                return a->operator->();
            }
        }
        std::cout << "=MakeNew=" << std::endl;
        m_as.push_back(m_f());
        return m_as.back()->operator->();
    }
    void clear() {
        std::lock_guard<std::mutex> guard(m_Mutex);
        std::cout << "---DeadPool---" << std::endl;
        for (auto const& a : m_as) {
            // FAIL: can't send interrupt when exec() is ongoing (due to Exclusive)
            a->interrupt();
            // WTF: try_lock_for() not available by default ?
            // FAIL:(gcc4.8): uses MONOTONIC instead of STEADY clock in
            // ALT: for/sleep 25 times by 200ms and try to lock each time
            // auto locked = Lockable::lock_t(m_Mutexes[i], std::chrono::seconds(5));
            std::this_thread::sleep_for(std::chrono::milliseconds(200));

            // HACK: hold locks on all connections until .clear()->destroy()->release()
            if (!a->try_lock()) {
                throw std::logic_error("interrupt takes too long");
            }
        }
        m_as.clear();
    }
    make_new_t const m_f;
    mutable std::vector<std::unique_ptr<Accessor>> m_as;
    mutable std::mutex m_Mutex;
};

struct Proxy : Accessor {
    using lock_t = std::lock_guard<std::mutex>;
    Proxy() = default;
    virtual ~Proxy() = default;
    void interrupt() const override final {
        m_a->interrupt();
    }
    void use(std::unique_ptr<Accessor> a) {
        lock_t guard(m_Mutex);
        std::cout << "---Switch---" << std::endl;
        // NOTE: interrupt and destroy whole pool of connections
        // BUG?
        m_a = std::move(a);
    }
    Lockable operator->() const override final {
        // BET:(<C++14): use RW/S boost::shared_lock + boost::unique_lock
        lock_t guard(m_Mutex);
        std::cout << "Proxy->" << std::endl;
        if (!m_a) {
            throw std::logic_error("BUG: accessing empty proxy");
        }
        return m_a->operator->();
    }
    std::unique_ptr<Accessor> m_a;
    mutable std::mutex m_Mutex;
};

// NOTE: used as persistent member of all objects which use db
//   => required for shared->exec() syntax instead of unnatural (*proxysharedptr)->exec();
struct Shared : Accessor {
    Shared(std::shared_ptr<Accessor> a) : m_a(std::move(a)) {}
    virtual ~Shared() = default;
    void interrupt() const override final {
        m_a->interrupt();
    }
    Lockable operator->() const override final {
        std::cout << "Shared->" << std::endl;
        return m_a->operator->();
    }
    std::shared_ptr<Accessor> const m_a;
};

struct Manager {
    Manager() {
        for (auto const i : std::array<int,2>{1, 2}) {
            m_ps.emplace(i, std::make_shared<Proxy>());
        }
    }
    ~Manager() {
        for (auto const it : m_ps) {
            it.second->use(std::unique_ptr<Pool>());
        }
    }
    Shared get(int i) const { return Shared(m_ps.at(i)); }
    void activate(char id) const {
        auto fmakenew = [id]() {
            auto db = std::unique_ptr<IDB>(new MyDB(id));
            auto unsafe = std::unique_ptr<Accessor>(new Unsafe(std::move(db)));
            auto excl = std::unique_ptr<Accessor>(new Exclusive(std::move(unsafe)));
            return excl;
        };
        for (auto const it : m_ps) {
            it.second->use(std::unique_ptr<Pool>(new Pool(fmakenew)));
        }
    }
    std::map<int, std::shared_ptr<Proxy>> m_ps;
};

struct User {
    User(Shared&& db) : m_db(std::move(db)) {}
    void f() {
        try {
            m_db->exec();
        } catch (std::runtime_error const& exc) {
            std::cout << ":: " << exc.what() << std::endl;
        }
    }
    Shared m_db;
};

int main()
{
    Manager mgr;
    mgr.activate('A');
    std::thread service([&](){
        User user1(mgr.get(1));
        user1.f();  // runs A until interrupted
        user1.f();  // continues with B
    });
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
    mgr.activate('B');
    service.join();
    return 0;
}
