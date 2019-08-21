#include "example.hpp"

int iratio(int x, int y) {
    if (!y) throw std::domain_error("y=0");
    return x / y;
}
