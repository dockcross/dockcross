set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(MANYLINUX_2_34 TRUE)

set(cross_triple "aarch64-unknown-linux-gnu")
set(cross_root /usr/xcc/${cross_triple})

set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})
set(CMAKE_Fortran_COMPILER $ENV{FC})

set(CMAKE_CXX_FLAGS "-I ${cross_root}/include/")

list(APPEND CMAKE_FIND_ROOT_PATH ${CMAKE_PREFIX_PATH} ${cross_root} ${cross_root}/${cross_triple})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE STRING "")
set(CMAKE_SYSROOT ${cross_root}/${cross_triple}/sysroot)

set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-aarch64)
