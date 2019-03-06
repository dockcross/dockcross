FROM dockcross/base:latest
MAINTAINER Matt McCormick "matt.mccormick@kitware.com"

# This is for 32-bit ARMv7 Linux
#include "common.crosstool"

# The cross-compiling emulator
RUN apt-get update \
&& apt-get install -y \
  qemu-user \
  qemu-user-static \
&& apt-get clean --yes


# The CROSS_TRIPLE is a configured alias of the "aarch64-unknown-linux-gnueabi" target.
#ENV CROSS_TRIPLE armv7-unknown-linux-gnueabi
ENV CROSS_TRIPLE arm-cortexa8_neon-linux-gnueabihf
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

ENV DEFAULT_DOCKCROSS_IMAGE dockcross/linux-armv7a

COPY Toolchain.cmake ${CROSS_ROOT}/
ENV CMAKE_TOOLCHAIN_FILE ${CROSS_ROOT}/Toolchain.cmake

ENV PKG_CONFIG_PATH /usr/lib/arm-linux-gnueabihf/

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE=dockcross/linux-armv7a
ARG VERSION=latest
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
ENV DEFAULT_DOCKCROSS_IMAGE ${IMAGE}:${VERSION}
