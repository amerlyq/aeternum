//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
#include <cassert>
#include <chrono>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <mutex>
#include <vector>

struct IDB {
    virtual void exec() const = 0;
};

struct MyDB : IDB {
    MyDB(char id) : m_id(id) {}
    void exec() const override final {
        std::cout << "MyDB(" << m_id << ")" << std::endl;
    }
    char m_id;
};

struct Lockable;

struct Accessor {
    virtual Lockable operator->() const = 0;
    virtual explicit operator IDB const * () const {
        throw std::domain_error("not implemented");
    }
};

struct Lockable {
    using lock_t = std::unique_lock<std::mutex>;
    Lockable(Accessor const *const a, lock_t lock = lock_t())
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
    Lockable operator->() const override final {
        std::cout << "Unsafe->" << std::endl;
        return Lockable(this);
    }
    explicit operator IDB const * () const override final {
        return m_db.get();
    }
    std::unique_ptr<IDB> const m_db;
};

struct Exclusive : Accessor {
    Exclusive(std::unique_ptr<Accessor> a) : m_a(std::move(a)) {}
    Lockable operator->() const override final {
        std::cout << "Exclusive->" << std::endl;
        auto locked = Lockable::lock_t(m_Mutex, std::try_to_lock);
        if (!locked) {
            throw std::logic_error("simultaneous access is forbidden");
        }
        return Lockable(m_a.get(), std::move(locked));
    }
    std::unique_ptr<Accessor> const m_a;
    mutable std::mutex m_Mutex;
};

struct Pool : Accessor {
    using make_new_t = std::function<std::unique_ptr<Accessor>(void)>;
    Pool(make_new_t f) : m_f(std::move(f)) {}
    ~Pool() noexcept {
        std::lock_guard<std::mutex> guard(m_Guard);
        for (int i=0; i<m_Mutexes.size(); ++i) {
            // NEED: m_as[i]->apply(sqlite3_interrupt);
            // WTF: try_lock_for() not available by default ?
            // auto locked = Lockable::lock_t(m_Mutexes[i], std::chrono::seconds(5));
            auto locked = Lockable::lock_t(*m_Mutexes[i], std::try_to_lock);
            if (!locked) {
                // throw std::logic_error("interrupt takes too long");
                abort();
            }
            m_as[i].reset();
        }
        m_as.clear();
        m_Mutexes.clear();
    }
    Lockable operator->() const override final {
        // FAIL: won't save us, if we are blocked after somebody called dtor()
        std::lock_guard<std::mutex> guard(m_Guard);
        std::cout << "Pool->" << std::endl;
        for (int i=0; i<m_Mutexes.size(); ++i) {
            auto locked = Lockable::lock_t(*m_Mutexes[i], std::try_to_lock);
            if (locked) {
                return Lockable(m_as[i].get(), std::move(locked));
            }
        }
        m_as.emplace_back(m_f());
        m_Mutexes.emplace_back();
        // BUG: Operation not permitted
        auto locked = Lockable::lock_t(*m_Mutexes.back());
        std::cout << "=MakeNew=" << std::endl;
        return Lockable(m_as.back().get(), std::move(locked));
    }
    make_new_t const m_f;
    mutable std::vector<std::unique_ptr<Accessor>> m_as;
    // WTF: mutex don't have move-ctor ? => must wrap
    mutable std::vector<std::unique_ptr<std::mutex>> m_Mutexes;
    mutable std::mutex m_Guard;
};

struct Proxy : Accessor {
    using lock_t = std::lock_guard<std::mutex>;
    Proxy() = default;
    void use(std::unique_ptr<Accessor> a) {
        lock_t guard(m_Mutex);
        m_a = std::move(a);
    }
    Lockable operator->() const override final {
        // BET:(<C++14): use RW/S boost::shared_lock + boost::unique_lock
        lock_t guard(m_Mutex);
        std::cout << "Proxy->" << std::endl;
        return m_a->operator->();
    }
    std::unique_ptr<Accessor> m_a;
    mutable std::mutex m_Mutex;
};

struct Shared : Accessor {
    Shared(std::shared_ptr<Accessor> a) : m_a(std::move(a)) {}
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
            it.second->use(std::unique_ptr<Accessor>(new Pool(fmakenew)));
        }
    }
    std::map<int, std::shared_ptr<Proxy>> m_ps;
};

struct User {
    User(Shared&& db) : m_db(std::move(db)) {}
    void f() {
        m_db->exec();
    }
    Shared m_db;
};

int main()
{
    Manager mgr;
    mgr.activate('A');
    User user1(mgr.get(1));
    user1.f();
    return 0;
}
