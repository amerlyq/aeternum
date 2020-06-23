#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: 2020 Amerlyq <amerlyq@gmail.com>
#
# SPDX-License-Identifier: MIT
#
"""
Python app boilerplate for standalone scripts inside features

USAGE:
  $ ./alt
  $ ./command/alt.py
  $ ./<feature>/<command>.py
"""

print(f'#1s file={__file__} pkg={__package__} nm={__name__}')

if __name__ == '__main__' and __package__ is None:
    import sys, os, os.path as fs
    here = fs.abspath(fs.dirname(__file__))
    there = fs.dirname(fs.realpath(__file__))
    top = fs.dirname(there)
    for autodir in here, there, top, os.getcwd():
        try:
            sys.path.remove(autodir)
        except ValueError:
            pass

    # FAIL: exposes mods from the outside top-dir
    #   BET:HACK: use rel-symlink inside empty dir
    # sys.path.insert(0, fs.dirname(top))
    # __package__ = fs.basename(top)

    sys.path.insert(0, fs.join(top, 'main'))
    __package__ = '.'.join(['project', fs.basename(there)])

    print(sys.path)

print(f'#2 file={__file__} pkg={__package__} nm={__name__}')

from .run import main

if __name__ == '__main__':
    main()
