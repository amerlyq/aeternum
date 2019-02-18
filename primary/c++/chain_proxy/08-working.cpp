//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
#include <iostream>
#include <memory>

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
    Lockable(Accessor const *b_, int lock) : b(b_) { std::cout << "*lock*" << std::endl; }
    ~Lockable() { std::cout << "*unlock*" << std::endl; }

    explicit Lockable(Lockable const&) = delete;
    Lockable& operator=(Lockable const&) = delete;
    Lockable(Lockable&&) = default;
    Lockable& operator=(Lockable&&) = default;

    IDB const * operator->() {
        std::cout << "Lockable->" << std::endl;
        return static_cast<IDB const *>(*b);
    }
    Accessor const * b;
};

struct Unsafe : Accessor {
    Unsafe(IDB const * db_) : db(db_) {}
    Lockable operator->() const override final {
        std::cout << "Unsafe->" << std::endl;
        return Lockable(this, 0);
    }
    explicit operator IDB const * () const override final {
        return db;
    }
    IDB const * db;
};

struct Exclusive : Accessor {
    Exclusive(Accessor *b_) : b(b_) {}
    Lockable operator->() const override final {
        std::cout << "Exclusive->" << std::endl;
        return Lockable(b, 1);
    }
    Accessor* b;
};

// template <typename T>  => create pool of T objects related to accessor
struct Pool : Accessor {
    Pool(Accessor *b_) : b(b_) {}
    Lockable operator->() const override final {
        std::cout << "Pool->" << std::endl;
        return b->operator->();
    }
    Accessor* b;
};

struct Proxy : Accessor {
    Proxy(Accessor *b_) : b(b_) {}
    Lockable operator->() const override final {
        std::cout << "Proxy->" << std::endl;
        return b->operator->();
        if (!b) {
            throw std::logic_error("BUG: accessing empty proxy");
        }
    }
    Accessor* b;
};


int main()
{
    MyDB db;
    Unsafe unsafe(&db);
    // Exclusive unsafe(nullptr);  // NOTE: will throw
    Exclusive excl(&unsafe);
    Pool pool(&excl);
    auto mngr = std::unique_ptr<Proxy>(new Proxy(&pool));
    (*mngr)->exec();
    return 0;
}
