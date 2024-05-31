# Contributing

## Getting started

## How to add a new image ? (With crosstool-ng)

In this part, we will see how to add a new image, we will take example with `linux-arm64` for a raspberry pi 4, with [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng).

### Build and config crosstool-ng

To start, you need to download the source code of crosstool-ng:

```bash
git clone --recurse-submodules --remote-submodules https://github.com/crosstool-ng/crosstool-ng.git
```

Go to crosstool-ng folder:

```bash
cd crosstool-ng
```

Change git branch:

```bash
git checkout crosstool-ng-1.26.0
```

Once in the **crosstool-ng** folder, you must first run the `bootstrap` script:

```bash
./bootstrap
```

Then run the `configure` script:

*Note: `-enable-local` does a portable install of crosstool-ng.*:

```bash
./configure --enable-local
```

Finally, launch the building of crosstool-ng:

```bash
make -j$(nproc)
```

Once the crosstool-ng build is complete, you can run this command to test crosstool-ng:

```bash
./ct-ng --version
```

Before starting the configuration of the toolchains, i recommend you to use one of the examples from crosstool-ng and then make your changes, the command to display the examples:

```bash
./ct-ng list-samples
```

We will take the example of `aarch64-rpi4-linux-gnu`, a `.config` file will be created:

```bash
./ct-ng aarch64-rpi4-linux-gnu
```

*Alternatively*, we could copy an existing `crosstool-ng.config` from one of the target folders in the `dockcross` project to the local `.config`:

```bash
cp path/to/dockcross/linux-arm64/crosstool-ng.config .config
```

We will configure the toolchains according to our needs:

```bash
./ct-ng menuconfig
```

Once the modifications are made, we will display the name of the toolchains, it will be useful later:

```bash
./ct-ng show-tuple
```

### Configuring docker image

You must create a file with the **same** name of the docker image (`linux-arm64`).

Copy the `.config` of crosstool-ng to this file (`linux-arm64`) and rename it to `crosstool-ng.config`.

You need to create a file named `Toolchain.cmake` in `linux-arm64`.

Copy text to `Toolchain.cmake` file:

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR ARM64)

set(cross_triple $ENV{CROSS_TRIPLE})
set(cross_root $ENV{CROSS_ROOT})

set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})
set(CMAKE_Fortran_COMPILER $ENV{FC})

set(CMAKE_CXX_FLAGS "-I ${cross_root}/include/")

set(CMAKE_FIND_ROOT_PATH ${cross_root} ${cross_root}/${cross_triple})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_SYSROOT ${cross_root}/${cross_triple}/sysroot)

set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-arm64)
```

Then you must change these lines according to the targeted architecture, here **ARM64**:

```cmake
set(CMAKE_SYSTEM_PROCESSOR ARM64)
set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-arm64)
```

Then you must create a file named `Dockerfile.in` in the image folder (`linux-arm64`).

Copy text to `Dockerfile.in` file:

```docker
ARG ORG=dockcross
FROM ${ORG}/base:latest

LABEL maintainer="Matt McCormick matt.mccormick@kitware.com"

# This is for 64-bit ARM Linux machine

# Crosstool-ng crosstool-ng-1.26.0 2023-09-24
ENV CT_VERSION crosstool-ng-1.26.0

#include "common.crosstool"

# The cross-compiling emulator
RUN apt-get update \
&& apt-get install -y \
  qemu-user \
  qemu-user-static \
&& apt-get clean --yes

# The CROSS_TRIPLE is a configured alias of the "aarch64-unknown-linux-gnu" target.
ENV CROSS_TRIPLE aarch64-unknown-linux-gnu

ENV CROSS_ROOT ${XCC_PREFIX}/${CROSS_TRIPLE}
ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-g++ \
    LD=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ld \
    FC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gfortran

ENV QEMU_LD_PREFIX "${CROSS_ROOT}/${CROSS_TRIPLE}/sysroot"
ENV QEMU_SET_ENV "LD_LIBRARY_PATH=${CROSS_ROOT}/lib:${QEMU_LD_PREFIX}"

COPY Toolchain.cmake ${CROSS_ROOT}/
ENV CMAKE_TOOLCHAIN_FILE ${CROSS_ROOT}/Toolchain.cmake

ENV PKG_CONFIG_PATH /usr/lib/aarch64-linux-gnu/pkgconfig

# Linux kernel cross compilation variables
ENV PATH ${PATH}:${CROSS_ROOT}/bin
ENV CROSS_COMPILE ${CROSS_TRIPLE}-
ENV ARCH arm64

#include "common.label-and-env"
```

Then you must change these lines according to the targeted architecture.

Here you have to change the value according to the name of the toolchain (./ct-ng show-tuple):

```docker
ENV CROSS_TRIPLE aarch64-unknown-linux-gnu
```

These lines also need to be changed:

```docker
LABEL maintainer="Matt McCormick matt.mccormick@kitware.com"
ENV PKG_CONFIG_PATH /usr/lib/aarch64-linux-gnu/pkgconfig
ENV ARCH arm64
```

Once this part is finished, there must be 3 files in the `linux-arm64` folder:

- **`crosstool-ng.config`**, the configuration of the toolchain/crosstool-ng.
- **`Dockerfile.in`**, the docker file.
- **`Toolchain.cmake`**, the CMake file for the toolchains.

### Makefile

For this last part, we will see how to add the image to the [Makefile](Makefile) and to a github action.

You need to add the image/folder name (**linux-arm64**) to the **STANDARD_IMAGES** variable in the [Makefile](Makefile):

```make
# These images are built using the "build implicit rule"
STANDARD_IMAGES = android-arm android-arm64 android-x86 android-x86_64 \
 linux-x86 linux-x64 linux-x64-clang linux-arm64 linux-arm64-musl linux-arm64-full \
 linux-armv5 linux-armv5-musl linux-armv5-uclibc linux-m68k-uclibc linux-s390x linux-x64-tinycc \
 linux-armv6 linux-armv6-lts linux-armv6-musl linux-arm64-lts \
 linux-armv7l-musl linux-armv7 linux-armv7a linux-armv7-lts linux-x86_64-full \
 linux-mips linux-ppc64le linux-riscv64 linux-riscv32 linux-xtensa-uclibc \
 web-wasi \
 windows-static-x86 windows-static-x64 windows-static-x64-posix windows-armv7 \
 windows-shared-x86 windows-shared-x64 windows-shared-x64-posix windows-arm64
```

You need to add the image/folder name (`linux-arm64`) to the `GEN_IMAGES` variable in the [Makefile](Makefile):

```make
# Generated Dockerfiles.
GEN_IMAGES = android-arm android-arm64 \
 linux-x86 linux-x64 linux-x64-clang linux-arm64 linux-arm64-musl linux-arm64-full \
 manylinux2014-x64 manylinux2014-x86 \
 manylinux2014-aarch64 linux-arm64-lts \
 web-wasm web-wasi linux-mips windows-arm64 windows-armv7 \
 windows-static-x86 windows-static-x64 windows-static-x64-posix \
 windows-shared-x86 windows-shared-x64 windows-shared-x64-posix \
 linux-armv7 linux-armv7a linux-armv7l-musl linux-armv7-lts linux-x86_64-full \
 linux-armv6 linux-armv6-lts linux-armv6-musl \
 linux-armv5 linux-armv5-musl linux-armv5-uclibc linux-ppc64le linux-s390x \
 linux-riscv64 linux-riscv32 linux-m68k-uclibc linux-x64-tinycc linux-xtensa-uclibc
```

### Image building and testing

You can now start building the image:

```bash
make linux-arm64
```

When finished, you can test it:

```bash
make linux-arm64.test
```

If you want to go a little further in the tests:

```bash
docker run --rm linux-arm64 > ./linux-arm64
chmod +x ./linux-arm64
```

And then run the commands to build a project (you must be in the directory of your project to build):

```bash
./linux-arm64 make
```

With CMake + Ninja:

```bash
./linux-arm64 cmake -Bbuild -S. -GNinja
./linux-arm64 ninja -Cbuild
```

### CI (github action)

To finish, you have to add to `.github/workflows/main.yml` the image/folder name:

```yml
          # Linux arm64/armv8 images
          - {
              image: "linux-arm64",
              stockfish: "yes",
              stockfish_arg: "ARCH=armv8",
              ninja: "yes",
              ninja_arg: "",
              openssl: "yes",
              openssl_arg: "linux-aarch64",
              C: "yes",
              C_arg: "",
              C-Plus-Plus: "yes",
              C-Plus-Plus_arg: "",
              fmt: "yes",
              fmt_arg: "",
              cpython: "yes",
              cpython_arg: "--host=aarch64-unknown-linux-gnu --target=aarch64-unknown-linux-gnu",
            }
```

You can disable and enable the build of certain tests which can cause problems with certain CPU architectures (eg. OpenSSL with Risc-V...).
