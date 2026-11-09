#!/bin/sh
set -eu
cd "$(dirname "$0")"
${CXX:-c++} -std=c++11 -O3 -flto -Wall -Wextra -pedantic ntv4004.cxx i4004.cxx -o ntv4004
${CXX:-c++} -std=c++11 -O3 -flto -Wall -Wextra -pedantic intel/pdp10.cxx -o intel/pdp10
