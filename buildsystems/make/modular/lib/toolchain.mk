#%BET:(include into ALL): export MAKEFILES="/path/to/toolchain.mk ..."
#%BUT:
#  !! it is not an error if the files listed in MAKEFILES are not found
#  + default goal is never taken from one of these makefiles (or any makefile included by them)
#  * main use of MAKEFILES is in inner communication between recursive invocations of make
#    <= not desirable to set the environment variable before a top-level invocation of make

#%USAGE: export MAKEFLAGS="-I /path/to/toolchains/"
#%CHECK:ALT: export .INCLUDE_DIRS="/path/to/toolchains/ ..."
# -include toolchain.mk

#%ATT: optional "-include" must be suppressed explicitly (accumulated only when present/read)
# toolchain.mk: ;
