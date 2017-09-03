set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(cross_triple "x86_64-linux-gnu")

set(CMAKE_C_COMPILER /opt/rh/devtoolset-2/root/usr/bin/gcc)
set(CMAKE_CXX_COMPILER /opt/rh/devtoolset-2/root/usr/bin/g++)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_Fortran_COMPILER /opt/rh/devtoolset-2/root/usr/bin/gfortran)

set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/${cross_triple}-noop)
