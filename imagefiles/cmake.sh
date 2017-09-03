#!/bin/sh

# Always pass the CMAKE_TOOLCHAIN_FILE variable to CMake when inside a
# dockcross environment -- the CMAKE_TOOLCHAIN_FILE environmental variable is
# always set in this context

# Exception:
#
# Do not pass the toolchain when calling CMake with these options:
#   -E                           = CMake command mode.
#   --build <dir>                = Build a CMake-generated project binary tree.
#   --find-package               = Run in pkg-config like mode.
#
case $1 in

  -E|--build|--find-package)
      exec /usr/bin/cmake "$@"
      ;;

esac

exec /usr/bin/cmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_TOOLCHAIN_FILE} "$@"
