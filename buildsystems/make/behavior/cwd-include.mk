#!/usr/bin/env -S make --silent -f
#%SUMMARY: demo for here/this when [-f|include] makefiles
#%USAGE: $ ./$0 [-C|-I] /path/to/dir [args] [--] [tgts]

#%WARN: need relpath; error if not in cwd; use -I outside
include cwd-here.mk

#%NOTE: can be used to load cross-toolchain only if supplied, ignored otherwise
#%USAGE:(in parent make): MAKEFLAGS += -I/path/to/toolchains
-include toolchain.mk
