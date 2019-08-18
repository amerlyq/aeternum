// What's a template template parameter?
// Is a template template parameter==template parameter?

// A template template parameter (will refer to this a TTP below) is not a typo
// for template parameter. A TTP is a template parameter that is a template
// itself. Template parameters can take a few different forms. For instance,
// this uses a template type parameter:

template <typename T>
class Comeau {
    // ...
    T goodstuff;
};
// ...
Comeau<int> C;
// There are also template non-type parameters, passed as constants, for
// instance:
template <int NumberOfPlatforms>
class Where {
    // ...
    int counts[NumberOfPlatforms];
};
// ...
Where<50> total;
// And so on. As well, you are also allowed to pass a template to a template.
// Consider the following template template parameter:
template <template <typename T> class Product>
class sales {
    // ...
    Product<int> P;
};
// ...
sales<Comeau> S;

// TTPs provide for yet another level of abstraction capability in C++.
// Compilers are only recently supporting them (mid-2000), so make sure that
// your particular compiler does before trying to use them (if not, error
// messages will be confusing). On this point: Don't just assume that because
// your compiler is popular and/or because the vendor lies and claims
// conformance that their compiler really supports everything.
