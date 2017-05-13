set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(cross_triple $ENV{CROSS_TRIPLE})
set(cross_root $ENV{CROSS_ROOT})

set(CMAKE_C_COMPILER ${cross_root}/${cross_triple}-gcc)
set(CMAKE_CXX_COMPILER ${cross_root}/${cross_triple}-g++)
set(CMAKE_Fortran_COMPILER ${cross_root}/${cross_triple}-gfortran)

set(CMAKE_FIND_ROOT_PATH  ${cross_root}/${cross_triple})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
set(CMAKE_LINK_SEARCH_START_STATIC TRUE)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_C_FLAGS_INIT "--specs=nosys.specs")
set(CMAKE_CXX_FLAGS_INIT "--specs=nosys.specs")

#
# Remarks:
#
# (1) Linking c++ executable triggers this error:
#
#   undefined reference to `__sync_synchronize'
#
# (2) Add support for "Architecture options usage"
#     See /opt/gcc-arm-none-eabi-6-2017-q1-update/share/doc/gcc-arm-none-eabi/readme.txt
#
# (3) Provide mechanism to switch spec (rdimon.specs , nano.specs, ...)
#
# (4) Look into seg fault when trying to use qemu-arm:
#
#       How to reproduce ?
#          - uncomment "--emulator "/usr/bin/qemu-arm -cpu cortex-m3" in Makefile
#          - make linux-arm-cortex.test
#
#       Suggestions: 
#       - may be the version of the emulator should be updated ?
#       - may be the selected cpu model need to match some flag we need to set based on (2) ?
#

set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-arm)

