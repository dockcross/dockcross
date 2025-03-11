set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR riscv32)

set(cross_triple $ENV{CROSS_TRIPLE})
set(cross_root $ENV{CROSS_ROOT})

set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})
set(CMAKE_Fortran_COMPILER $ENV{FC})

set(CMAKE_CXX_FLAGS "-I ${cross_root}/include/")

list(APPEND CMAKE_FIND_ROOT_PATH ${CMAKE_PREFIX_PATH} ${cross_root} ${cross_root}/${cross_triple})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_SYSROOT ${cross_root}/${cross_triple}/sysroot)


set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-riscv32)

# Discard path returned by pkg-config and associated with HINTS in module
# like FindOpenSSL.
# set(CMAKE_IGNORE_PATH /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/lib/)

# set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-riscv32)
