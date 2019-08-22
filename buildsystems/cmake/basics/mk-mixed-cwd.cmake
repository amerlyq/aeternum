#!/bin/sh -reufC
#[[ -*- mode: cmake; -*-
cmake -E make_directory "${t:=${TMPDIR:-/tmp}/${f:=$(realpath -s "$0")}}"
make -C "$t" -srRf- -- f="$f" n="${n:=main}" <<'EOT'
$n: CMakeCache.txt ; cmake --build . --target '$@'
CMakeCache.txt: CMakeLists.txt ; cmake -S. -B. -DNAME='$n' -Werror=dev
CMakeLists.txt: $f ; cp -f '$<' '$@'
EOT
cmake -E chdir "$t" ${RUN-} ./"$n" "$@"
exit
]]
#%SUMMARY: makefile shebang augmented by shell
#%USAGE: $ ./$0 [readelf -Wa]
#%
cmake_minimum_required(VERSION 3.6.3)
project(${NAME} CXX)

file(WRITE ${PROJECT_BINARY_DIR}/${NAME}.cpp "int main(){ return 71; }\n")

add_executable(${PROJECT_NAME} ${NAME}.cpp)
