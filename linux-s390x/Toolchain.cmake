set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR s390x)

set(cross_triple "s390x-ibm-linux-gnu")
set(cross_root /usr/xcc/${cross_triple})

set(CMAKE_C_COMPILER ${cross_root}/bin/${cross_triple}-gcc)
set(CMAKE_CXX_COMPILER ${cross_root}/bin/${cross_triple}-g++)
set(CMAKE_Fortran_COMPILER ${cross_root}/bin/${cross_triple}-gfortran)

set(CMAKE_FIND_ROOT_PATH ${cross_root}/lib ${cross_root}/${cross_triple}/lib)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-s390x)
