#!/usr/bin/env python3


# SEE:(CachedAttribute):
#   https://stackoverflow.com/questions/7388258/replace-property-for-perfomance-gain
#   https://stackoverflow.com/questions/12084445/python-change-a-property-getter-after-the-fact
class cached_property(object):
    def __init__(self, method, name=None):
        self._method = method
        self._name = name or method.__name__
        self.__doc__ = method.__doc__
        # self.__module__ = method.__module__

    def __get__(self, obj, type=None):
        print('!!! access !!!')
        if obj is None:
            return self  # static access to Class.attr
        ## WTF? guard for direct calls ? ::: seems like no need
        ##   SEE: https://docs.python.org/3/howto/descriptor.html
        # try:
        #     value = obj.__dict__[self._name]
        #     # BAD:(recursion): value = getattr(obj, self._name)
        # except KeyError:  # redefine instance attribute
        value = self._method(obj)
        print('!!! reassign !!!')
        # OR: obj.__dict__[self._name] = value
        setattr(obj, self._name, value)
        return value


class A(object):
    @cached_property
    def attr(self):
        print('!!! call !!!')
        return 5*5


if __name__ == '__main__':
    a = A()
    print(vars(a))

    print(a.attr)
    print(a.attr)
    print(a.attr)
    print(getattr(a, 'attr'))

    del a.attr  # invalidate
    print(a.attr)
    print(a.attr)

    print(vars(a))
