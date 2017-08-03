#!/usr/bin/env python3


class A(object):
    def __init__(self):
        self._data = set()

    @property
    def data(self):
        return self._data

    @data.setter
    def data(self, value):
        self._data = value

    def __getattr__(self, attr):
        print(attr)
        return getattr(self.data, attr)

    def add(self, item):
        print(item)
        self.data.add(item)


if __name__ == '__main__':
    a = A()
    print(a.data)
    print(a.add)
    print(a.update)
    print(a.__iter__)
    # BAD: https://docs.python.org/3/reference/datamodel.html#special-method-lookup
    #   ::: len()/iter()/etc bypasses __getattr__
    print(iter(a))
