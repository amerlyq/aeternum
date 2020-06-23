#
# SPDX-FileCopyrightText: 2020 Amerlyq <amerlyq@gmail.com>
#
# SPDX-License-Identifier: CC0-1.0
#
"""
Main entry point for modules

USAGE:
  $ PYTHONPATH=main python -m project
  $ PYTHONPATH="${PWD%/*}" python -m "${PWD##*/}"
"""
print(f'#1m file={__file__} pkg={__package__} nm={__name__}')

from .command.run import main
main()
