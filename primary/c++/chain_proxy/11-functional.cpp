//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
#include <functional>
#include <iostream>
#include <map>
#include <memory>
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
    Lockable(Accessor const * const a, int lock) : m_a(a) {
        std::cout << "*lock*" << std::endl;
    }
    ~Lockable() { std::cout << "*unlock*" << std::endl; }

    explicit Lockable(Lockable const&) = delete;
    Lockable& operator=(Lockable const&) = delete;
    Lockable(Lockable&&) = default;
    Lockable& operator=(Lockable&&) = default;

    IDB const * operator->() {
        std::cout << "Lockable->" << std::endl;
        return static_cast<IDB const *>(*m_a);
    }
    Accessor const * const m_a;
};

struct Unsafe : Accessor {
    Unsafe(std::unique_ptr<IDB> db) : m_db(std::move(db)) {}
    Lockable operator->() const override final {
        std::cout << "Unsafe->" << std::endl;
        return Lockable(this, 0);
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
        return Lockable(m_a.get(), 1);
    }
    std::unique_ptr<Accessor> const m_a;
};

struct Pool : Accessor {
    using make_new_t = std::function<std::unique_ptr<Accessor>(void)>;
    Pool(make_new_t f) : m_f(std::move(f)) {}
    Lockable operator->() const override final {
        std::cout << "Pool->" << std::endl;
        for (auto const& a : m_as) {
            return a->operator->();
        }
        m_as.emplace_back(m_f());
        return m_as.back()->operator->();
    }
    make_new_t const m_f;
    mutable std::vector<std::unique_ptr<Accessor>> m_as;
};

struct Proxy : Accessor {
    Proxy() = default;
    void use(std::unique_ptr<Accessor> a) {
        m_a = std::move(a);
    }
    Lockable operator->() const override final {
        std::cout << "Proxy->" << std::endl;
        return m_a->operator->();
    }
    std::unique_ptr<Accessor> m_a;
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
    // User user2(mgr.get(1));
    // user2.f();
    return 0;
}
