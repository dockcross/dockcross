FROM dockcross/base:latest
MAINTAINER Matt McCormick "matt.mccormick@kitware.com"

# This is for ARMv5 "legacy" (armel) devices which do NOT support hard float
# VFP instructions (armhf).

# From https://wiki.debian.org/CrossToolchains, installing for jessie
RUN echo "deb http://emdebian.org/tools/debian/ jessie main" > /etc/apt/sources.list.d/emdebian.list \
&& curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - \
&& sed -i 's/httpredir.debian.org/http.debian.net/' /etc/apt/sources.list \
&& dpkg --add-architecture armel \
&& apt-get update && apt-get install -y crossbuild-essential-armel

# The cross-compiling emulator
RUN apt-get update && apt-get install -y \
  qemu-user \
  qemu-user-static

ENV CROSS_TRIPLE arm-linux-gnueabi
ENV CROSS_ROOT /usr/bin
ENV AS=/usr/bin/${CROSS_TRIPLE}-as \
    AR=/usr/bin/${CROSS_TRIPLE}-ar \
    CC=/usr/bin/${CROSS_TRIPLE}-gcc \
    CPP=/usr/bin/${CROSS_TRIPLE}-cpp-4.9 \
    CXX=/usr/bin/${CROSS_TRIPLE}-g++ \
    LD=/usr/bin/${CROSS_TRIPLE}-ld

ENV QEMU_LD_PREFIX ${CROSS_ROOT}/libc
ENV QEMU_SET_ENV "LD_LIBRARY_PATH=${CROSS_ROOT}/lib:${CROSS_ROOT}/libc/lib/${CROSS_TRIPLE}/"

ENV DEFAULT_DOCKCROSS_IMAGE dockcross/linux-armv5

COPY Toolchain.cmake ${CROSS_ROOT}/
ENV CMAKE_TOOLCHAIN_FILE ${CROSS_ROOT}/Toolchain.cmake

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
