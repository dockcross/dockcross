set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 1)

set(cross_triple arm-linux-androideabi)
set(CMAKE_ANDROID_STANDALONE_TOOLCHAIN /usr/${cross_triple}/)
set(CMAKE_ANDROID_ARM_MODE 1)
set(CMAKE_ANDROID_ARM_NEON 1)

set(CMAKE_C_COMPILER /usr/${cross_triple}/bin/${cross_triple}-gcc)
set(CMAKE_CXX_COMPILER /usr/${cross_triple}/bin/${cross_triple}-g++)

set(CMAKE_FIND_ROOT_PATH /usr/${cross_triple})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_SYSROOT /usr/${cross_triple}/sysroot)

set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-arm)
