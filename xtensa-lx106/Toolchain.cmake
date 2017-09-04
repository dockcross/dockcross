set(CMAKE_SYSTEM_NAME elf)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR xtensa)

set(cross_triple "xtensa-lx106-elf")

set(CMAKE_C_COMPILER /usr/bin/${cross_triple}-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/${cross_triple}-g++)

set(CMAKE_FIND_ROOT_PATH /usr/${cross_triple} /usr/${cross_triple}/libc/usr)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# http://wiki.linux-xtensa.org/index.php/Xtensa_on_QEMU
set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-xtensa)
