//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
#include <iostream>
#include <memory>

// NOTE: everything could be constructed on stack beside Proxy
//  => Pool can use pre-allocated std::array<> to be on stack
//  => Proxy also could be template-created boost::optional to be on stack
// BUT: proxy is good precisely because it can be anything of chosen types

struct IDB {
    virtual void exec() const = 0;
};

struct MyDB : IDB {
    void exec() const override final {
        std::cout << "MyDB()" << std::endl;
    }
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

// template <typename T>  => create pool of T objects related to accessor
struct Pool : Accessor {
    Pool(std::unique_ptr<Accessor> a) : m_a(std::move(a)) {}
    Lockable operator->() const override final {
        std::cout << "Pool->" << std::endl;
        return m_a->operator->();
    }
    std::unique_ptr<Accessor> const m_a;
};

struct Proxy : Accessor {
    Proxy(std::unique_ptr<Accessor> a) : m_a(std::move(a)) {}
    Lockable operator->() const override final {
        std::cout << "Proxy->" << std::endl;
        return m_a->operator->();
    }
    std::unique_ptr<Accessor> const m_a;
};


int main()
{
    auto db = std::unique_ptr<IDB>(new MyDB());
    auto unsafe = std::unique_ptr<Accessor>(new Unsafe(std::move(db)));
    auto excl = std::unique_ptr<Accessor>(new Exclusive(std::move(unsafe)));
    auto pool = std::unique_ptr<Accessor>(new Pool(std::move(excl)));
    auto mngr = std::unique_ptr<Accessor>(new Proxy(std::move(pool)));
    (*mngr)->exec();
    return 0;
}
