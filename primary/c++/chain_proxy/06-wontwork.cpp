//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
#include <iostream>
#include <memory>

struct IDB {
    virtual ~IDB() = default;
    virtual void exec() const = 0;
};

struct MyDB : IDB {
    void exec() const override final {
        std::cout << "MyDB()" << std::endl;
    }
};

struct Accessor {
    virtual ~Accessor() = default;
    virtual IDB* operator->() const = 0;
};

struct Unsafe : Accessor {
    Unsafe(IDB *db_) : db(db_) {}
    IDB* operator->() const override final {
        std::cout << "Unsafe->" << std::endl;
        return db;
    }
    IDB* db;
};

struct Locked : Accessor {
    Locked(Accessor *b_, int lock) : b(b_) { std::cout << "[lock]" << std::endl; }
    ~Locked() { std::cout << "[unlock]" << std::endl; }
    IDB* operator->() const override final {
        std::cout << "Locked->" << std::endl;
        return b->operator->();
    }
    Accessor* b;
};

struct Exclusive : Accessor {
    Exclusive(Accessor *b_) : b(b_) {}
    Locked operator->() const {
        std::cout << "Exclusive->" << std::endl;
        return Locked(b, 5);
    }
    Accessor* b;
};

struct Pool : Accessor {
    Pool(Accessor *b_) : b(b_) {}
    IDB* operator->() const override final {
        std::cout << "Pool->" << std::endl;
        return b->operator->();
    }
    Accessor* b;
};

struct Proxy : Accessor {
    Proxy(Accessor *b_) : b(b_) {}
    IDB* operator->() const override final {
        std::cout << "Proxy->" << std::endl;
        return b->operator->();
    }
    Accessor* b;
};


int main()
{
    MyDB db;
    Unsafe unsafe(&db);
    Exclusive excl(&unsafe);
    Pool pool(&excl);
    auto mngr = std::unique_ptr<Proxy>(new Proxy(&pool));
    (*mngr)->exec();
    return 0;
}
