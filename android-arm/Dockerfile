# NOTE: Arguments are reset to empty after the FROM statement.
#       Unless they are not.
#       This funkyness is from Docker world: 
#       https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
#       https://docs.docker.com/engine/reference/builder/#scope
ARG DOCKCROSS_ORG=dockcross
ARG DOCKCROSS_VERSION=latest
FROM ${DOCKCROSS_ORG}/dockcross-base:${DOCKCROSS_VERSION}
ARG DOCKCROSS_ORG
ARG DOCKCROSS_VERSION

MAINTAINER Matt McCormick "matt.mccormick@kitware.com"

# The cross-compiling emulator
RUN apt-get update && apt-get install -y \
  qemu-user \
  qemu-user-static \
  unzip

ENV CROSS_TRIPLE=arm-linux-androideabi
ENV CROSS_ROOT=/usr/${CROSS_TRIPLE}
ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-clang \
    CPP=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-clang++ \
    LD=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ld \
    FC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gfortran

ENV ANDROID_NDK_REVISION 16b
ENV ANDROID_NDK_API 16
RUN mkdir -p /build && \
    cd /build && \
    curl -O https://dl.google.com/android/repository/android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip && \
    unzip ./android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip && \
    cd android-ndk-r${ANDROID_NDK_REVISION} && \
    ./build/tools/make_standalone_toolchain.py \
      --arch arm \
      --api ${ANDROID_NDK_API} \
      --stl=libc++ \
      --install-dir=${CROSS_ROOT} && \
    cd / && \
    rm -rf /build && \
    find ${CROSS_ROOT} -exec chmod a+r '{}' \; && \
    find ${CROSS_ROOT} -executable -exec chmod a+x '{}' \;

COPY Toolchain.cmake ${CROSS_ROOT}/
ENV CMAKE_TOOLCHAIN_FILE ${CROSS_ROOT}/Toolchain.cmake

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG DOCKCROSS_ORG=dockcross
ARG IMAGE=${DOCKCROSS_ORG}/android-arm
ARG DOCKCROSS_VERSION
ARG VCS_REF
ARG VCS_URL
LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.description=$IMAGE \
      org.opencontainers.image.documentation=$DOCKCROSS_URL \
      org.opencontainers.image.licenses="SPDX-License-Identifier: MIT" \
      org.opencontainers.image.ref.name=$IMAGE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source=$VCS_URL \
      org.opencontainers.image.title=$IMAGE \
      org.opencontainers.image.url=$DOCKCROSS_URL \
      org.opencontainers.image.vendor=$DOCKCROSS_ORG \
      org.opencontainers.image.version=$DOCKCROSS_VERSION
ENV DEFAULT_DOCKCROSS_IMAGE ${IMAGE}:${VERSION}
