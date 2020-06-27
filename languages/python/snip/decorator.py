#!/usr/bin/env python3

def aliases(*args):
    print('=@')
    def decorator(fn):
        print('=decor')
        if not hasattr(fn, 'aliases'):
            fn.aliases = []
        fn.aliases.extend(args)
        return fn
    return decorator

@aliases('f')
def foo(*args):
    print(args)

@aliases('b')
def bar(*args):
    print(args)

foo(1, 2, 3)
foo(4, 5)
foo(6)
print(foo.aliases)

bar('bar')
print(bar.aliases)
