set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(cross_triple "arm-none-eabi")
set(cross_root /usr/xcc/${cross_triple})

set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})

set(CMAKE_CXX_FLAGS "-I ${cross_root}/include/")

set(CMAKE_FIND_ROOT_PATH ${cross_root} ${cross_root}/${cross_triple})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
list(APPEND CMAKE_FIND_ROOT_PATH ${CMAKE_PREFIX_PATH})

set(CMAKE_EXE_LINKER_FLAGS "--specs=nosys.specs" CACHE INTERNAL "")
