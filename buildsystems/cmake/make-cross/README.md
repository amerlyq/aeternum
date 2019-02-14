# USAGE

```bash
# List allowed commands for this makefile
make help
```

Simple usage
```bash
# Build
make
make AA
make bdir=$HOME/_build-arm-release BB
make host
make host-Rcb
make host-Rttcb             # rebuild without tests (-DBUILD_TESTING=OFF)
make bdflt=gcc5 @-Rcb       # TODO: use '@' as placeholder for $bdflt
make clean-BB
make clean-host clean-gcc5

# Run binary products
make run
make run-host
make run-gcc5
make bdflt=gcc5 run
make test
make console
make dlt-daemon
```

Advanced workflow (both TARGET and HOST)
```bash
# look for possible flags == help from underlying scripts
make host-h

# build as always
make host
# build single thread (so build error will be the last one)
make host-
# build single thread with verbose "make" and "ld"
# => look at gcc link/compile cmdline executed directly before error occurs
make host-1bvvv
# immediately open errors log in editor
# => NEED: export EDITOR=vim, or export EDITOR=gedit
make host-e

# Pass additional directives in quotes
make "host-Rcb -DBUILD_TESTING=ON"
make host"-Rcb -DBUILD_TESTING=ON"
make host-Rcb" -DBUILD_TESTING=ON"
```

Parameters
```
# Build project with choosen prefix
make PJ_PREFIX_DIR=/data/_cache/_prefix-host host
# Build with auto prefix per target (-> /data/_cache/_prefix-gcc5)
make PJ_PREFIX_ROOT=/data/_cache gcc5

# Build into RAM disk
make broot=/tmp/pj host
make bpref=/tmp/pj/_build- gcc5
make bdir=/tmp/pj/_build-clang clang

# Available env vars for your ~/.bashrc
export PJ_PREFIX_DIR=/data/_cache/_prefix-gcc5
export PJ_PREFIX_ROOT=/data/_cache
export PJ_BUILD_ROOT=/tmp/pj
export PJ_BUILD_PREFIX=/tmp/pj/_build-
export PJ_BUILD_DIR=/tmp/pj/_build-gcc5
export PJ_BUILD_DEFAULT=gcc5
```
