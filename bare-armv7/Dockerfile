FROM debian:bullseye as build
LABEL maintainer="Chen Tao t.clydechen@gmail.com"

RUN mkdir -p /apps/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y \
    cmake \
    curl \
    g++ \
    gcc \
    gpg \
    make \
    pkg-config \
    wget \
    xz-utils

# Get the latest version of ccache and arm-gcc
RUN curl -s https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads | sed -n "s/^.*Arm GNU Toolchain: \(.*\)\s<.*$/\1/p" > ARM_GCC_LATEST_VERSION
RUN curl -s https://github.com/ccache/ccache/releases/latest | sed -n 's/^.*tag\/\(.*\)".*$/\1/p' > CCACHE_LATEST_VERSION
# Download CCACHE and signature file
RUN wget https://github.com/ccache/ccache/releases/download/$(cat CCACHE_LATEST_VERSION)/ccache-$(cat CCACHE_LATEST_VERSION | cut -c2-).tar.xz
RUN wget https://github.com/ccache/ccache/releases/download/$(cat CCACHE_LATEST_VERSION)/ccache-$(cat CCACHE_LATEST_VERSION | cut -c2-).tar.xz.asc
# Download GCC and signature file
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu/$(cat ARM_GCC_LATEST_VERSION)/binrel/gcc-arm-$(cat ARM_GCC_LATEST_VERSION)-x86_64-arm-none-eabi.tar.xz
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu/$(cat ARM_GCC_LATEST_VERSION)/binrel/gcc-arm-$(cat ARM_GCC_LATEST_VERSION)-x86_64-arm-none-eabi.tar.xz.sha256asc

# Check integrity of CCACHE. The docker build will stop if the integrity check is failed.
# Import CCACHE Public Key
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 996DDA075594ADB8
RUN gpg --verify ccache-$(cat CCACHE_LATEST_VERSION | cut -c2-).tar.xz.asc
# Check integrity of GCC. The docker build will stop if the integrity check is failed.
RUN sha256sum --check gcc-arm-$(cat ARM_GCC_LATEST_VERSION)-x86_64-arm-none-eabi.tar.xz.sha256asc

RUN tar -xvf gcc-arm-$(cat ARM_GCC_LATEST_VERSION)-x86_64-arm-none-eabi.tar.xz
RUN tar -xvf ccache-$(cat CCACHE_LATEST_VERSION | cut -c2-).tar.xz

# Build ccache
RUN cd ccache-$(cat CCACHE_LATEST_VERSION | cut -c2-); mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DHIREDIS_FROM_INTERNET=ON -DZSTD_FROM_INTERNET=ON .. && make -j`nproc` && cp ccache /apps/bin

# Remove v6 and v8 support for reducing image size
RUN rm -rf /gcc-arm-$(cat ARM_GCC_LATEST_VERSION)-x86_64-arm-none-eabi/arm-none-eabi/lib/thumb/v8*
RUN rm -rf /gcc-arm-$(cat ARM_GCC_LATEST_VERSION)-x86_64-arm-none-eabi/arm-none-eabi/lib/thumb/v6*
RUN mv /gcc-arm-$(cat ARM_GCC_LATEST_VERSION)-x86_64-arm-none-eabi /apps/gcc-arm-none-eabi

FROM debian:bullseye-slim as main

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y \
    cmake \
    dumb-init \
    make
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=build /apps /apps

# The compiler prefix is "arm-none-eabi-"
ENV PATH "/apps/bin:/apps/gcc-arm-none-eabi/bin:$PATH"
ENTRYPOINT [ "dumb-init", "--" ]