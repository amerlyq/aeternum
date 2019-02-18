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

struct Accessor : IDB {
    virtual ~Accessor() = default;
    virtual IDB* policy() const = 0;
    void exec() const override final {
        std::cout << "Accessor()" << std::endl;
        return policy()->exec();
    }
};

struct Unsafe : Accessor {
    Unsafe(IDB *db_) : db(db_) {}
    IDB* policy() const override final {
        std::cout << "Unsafe->" << std::endl;
        return db;
    }
    IDB* db;
};

struct Exclusive : Accessor {
    Exclusive(Accessor *b_) : b(b_) {}
    IDB* policy() const override final {
        std::cout << "Exclusive->" << std::endl;
        return b;
    }
    Accessor* b;
};

struct Pool : Accessor {
    Pool(Accessor *b_) : b(b_) {}
    IDB* policy() const override final {
        std::cout << "Pool->" << std::endl;
        return b;
    }
    Accessor* b;
};

struct Proxy : Accessor {
    Proxy(Accessor *b_) : b(b_) {}
    IDB* policy() const override final {
        std::cout << "Proxy->" << std::endl;
        return b;
    }
    Accessor* b;
};


int main()
{
    MyDB db;
    Unsafe unsafe(&db);
    Exclusive excl(&unsafe);
    Pool pool(&excl);
    Proxy proxy(&pool);
    Proxy* mngr = &proxy;
    mngr->exec();
    return 0;
}
