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

struct Lockable {
    Lockable(IDB *db_, int lock) : db(db_) { std::cout << "[lock]" << std::endl; }
    ~Lockable() { std::cout << "[unlock]" << std::endl; }

    IDB* operator->() const {
        std::cout << "Lockable->" << std::endl;
        return db;
    }
    IDB* db;
};

struct Accessor {
    virtual ~Accessor() = default;
    virtual Lockable operator->() const = 0;
};

struct Exclusive : Accessor {
    Exclusive(IDB *db_) : db(db_) {}
    Lockable operator->() const override final {
        std::cout << "Exclusive->" << std::endl;
        return Lockable(db, 5);
    }
    IDB* db;
};

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
    }
    Accessor* b;
};


int main()
{
    MyDB db;
    Exclusive excl(&db);
    Pool pool(&excl);
    auto mngr = std::unique_ptr<Proxy>(new Proxy(&pool));
    (*mngr)->exec();
    return 0;
}
