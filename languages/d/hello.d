#!/usr/bin/env rdmd
/+vim:ft=d

SPDX-FileCopyrightText: 2019 Amerlyq <amerlyq@gmail.com> and contributors

SPDX-License-Identifier: MIT

SUMMARY: hello world for D lang
USAGE: $ ./$0
+/

import std.stdio;

void main(string[] args)
{
    writeln("hello world");

    writefln("args.length = %d", args.length);

    foreach (index, arg; args)
    {
        writefln("args[%d] = '%s'", index, arg);
    }
}
