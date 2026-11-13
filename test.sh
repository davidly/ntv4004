#!/bin/sh
# Build, then run the CPU, C compiler, BASIC, assembler and INTERP/4 tests. The last two skip
# without Intel's images (see intel/README.md).
set -eu
cd "$(dirname "$0")"
./m.sh
for test in cpu fast cc basic basic_byte basic_large asm interp; do
    printf '\n=== tests/%s.py ===\n' "$test"
    "${PYTHON:-python3}" "tests/$test.py"
    if [ "$test" = cc ]; then
        printf '\n=== tests/%s.py --size ===\n' "$test"
        "${PYTHON:-python3}" "tests/$test.py" --size
    fi
done
