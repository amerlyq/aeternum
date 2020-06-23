#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: 2020 Amerlyq <amerlyq@gmail.com>
#
# SPDX-License-Identifier: MIT
#
"""
Scripts entry point

USAGE:
  $ ./ctl
  $ ./main/ctl.py
"""

print(f'#1s file={__file__} pkg={__package__} nm={__name__}')

from project.command.run import main

import sys
print(sys.path)

if __name__ == '__main__':
    main()
