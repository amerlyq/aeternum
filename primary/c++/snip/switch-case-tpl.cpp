//usr/bin/g++ -std=c++11 "$0" -o main.bin && exec ./main.bin; exit
// SUMMARY: switch-case made on templates with explicit instantiation
#include <string>
#include <iostream>

class A {
public:
    enum class E { X, Y };
    template <enum E>
    int f(int a) const;
};

template <>
int
A::f<A::E::X>(int a) const
{
    return 1 + a;
}

template <>
int
A::f<A::E::Y>(int a) const
{
    return 2 + a;
}

int main(){
    return A().f<A::E::X>(0);
}
