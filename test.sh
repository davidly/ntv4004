#!/bin/sh
# Build, then run the CPU, assembler and INTERP/4 tests. The last two skip
# without Intel's images (see intel/README.md).
set -eu
cd "$(dirname "$0")"
./m.sh
for test in cpu asm interp; do
    "${PYTHON:-python3}" "tests/$test.py"
done
