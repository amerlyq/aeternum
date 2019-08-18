//bin/mkdir -p "/tmp${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" "$@"
#include <iostream>

void print(char const* s) {
    std::cout << s << std::endl;
}

struct IBase {
    virtual ~IBase() = default;
    virtual void exec() const = 0;
};

struct Base : IBase {
    Base() { print("Base.ctor()"); }
    virtual ~Base() { print("Base.dtor()"); }
    void exec() const override { print("Base.exec()"); }
};

struct Derived : Base {
    Derived() { print("Derived.ctor()"); }
    virtual ~Derived() { print("Derived.dtor()"); }
    void exec() const final { print("Derived.exec()"); }
};

// NOTE:FAIL: Extended(IBase obj) : m_Obj(std::move(obj))
//   https://stackoverflow.com/questions/17642357/const-reference-vs-move-semantics
//   https://www.codesynthesis.com/~boris/blog/2012/06/19/efficient-argument-passing-cxx11-part1/
struct Extended : IBase {
    Extended(IBase const& obj) : m_Obj(obj) { print("Extended.ctor()"); }
    virtual ~Extended() { print("Extended.dtor()"); }
    void exec() const final { print("Extended.exec()"); m_Obj.exec(); }
    IBase const& m_Obj;
};

int main()
{
    std::cout << "--beg--" << std::endl;
    Extended(Derived()).exec();
    std::cout << "--end--" << std::endl;
    return 0;
}
