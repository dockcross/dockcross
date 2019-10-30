set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR mips)

set(cross_triple "mips-unknown-linux-gnu")
set(cross_root /usr/xcc/${cross_triple})

set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})
set(CMAKE_Fortran_COMPILER $ENV{FC})

# Search path for MIPS libraries
#   dpkg --add-architecture "mips"
#   apt-get install libcmocka-dev:mips
set(CMAKE_INCLUDE_PATH "/usr/lib/mips-include-gnu")
set(CMAKE_LIBRARY_PATH "/usr/lib/mips-linux-gnu")

set(CMAKE_C_FLAGS "-I${cross_root}/include/ -I${CMAKE_INCLUDE_PATH}")
set(CMAKE_CXX_FLAGS "-I${cross_root}/include/ -I${CMAKE_INCLUDE_PATH}")

set(CMAKE_FIND_ROOT_PATH ${cross_root} ${cross_root}/${cross_triple})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_SYSROOT ${cross_root}/${cross_triple}/sysroot)

set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-mips)
