#include <example.hpp>

#include <gtest/gtest.h>

TEST(Example, OkNonZero)
{
    EXPECT_EQ(3, iratio(10, 3));
}

TEST(Example, ErrZero)
{
    EXPECT_THROW(iratio(10, 0), std::domain_error);
}
