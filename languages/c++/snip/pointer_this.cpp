std::enable_shared_from_this

// Фича, которая позволяет возвращать shared_ptr на this, разделяя обязанности с уже имеющимися шарами,
// вместо создания ситуации, когда два разных шара отвечают за удаление одного объекта,
// не зная ничего друг о друге (и итого будет двойное удаление).

// A common implementation for enable_shared_from_this is to hold a weak
// reference (such as std::weak_ptr) to this. The constructors of
// std::shared_ptr can detect presence of a enable_shared_from_this base and
// share ownership with the existing std::shared_ptrs, instead of assuming the
// pointer is not managed by anyone else.

#include <memory>
#include <iostream>

struct Good: std::enable_shared_from_this<Good>
{
    std::shared_ptr<Good> getptr() {
        return shared_from_this();
    }
};

struct Bad
{
    std::shared_ptr<Bad> getptr() {
        return std::shared_ptr<Bad>(this);
    }
    ~Bad() { std::cout << "Bad::~Bad() called\n"; }
};

int main()
{
    // Good: the two shared_ptr's share the same object
    std::shared_ptr<Good> gp1(new Good);
    std::shared_ptr<Good> gp2 = gp1->getptr();
    std::cout << "gp2.use_count() = " << gp2.use_count() << '\n';

    // Bad, each shared_ptr thinks it's the only owner of the object
    std::shared_ptr<Bad> bp1(new Bad);
    std::shared_ptr<Bad> bp2 = bp1->getptr();
    std::cout << "bp2.use_count() = " << bp2.use_count() << '\n';
} // UB: double-delete of Bad


// Output:
gp2.use_count() = 2
bp2.use_count() = 1
Bad::~Bad() called
Bad::~Bad() called
*** glibc detected *** ./test: double free or corruption
