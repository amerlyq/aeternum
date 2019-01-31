//bin/true && exec make -{sf,o}/dev/null --eval='!:$X/$(basename $0);$<' --eval '$X/$0:$0;install -DT -- $< $@' "$@" 0="$(realpath "$0")" X="${TMPDIR:-/tmp}/cxx" CXXFLAGS="-I${0%/*}"
#include <common.hpp>
int main() { return 4; }
