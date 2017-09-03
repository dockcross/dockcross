#!/bin/sh

# Always pass the CMAKE_TOOLCHAIN_FILE variable to CMake when inside a
# dockcross environment -- the CMAKE_TOOLCHAIN_FILE environmental variable is
# always set in this context

exec /usr/bin/ccmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_TOOLCHAIN_FILE} "$@"
