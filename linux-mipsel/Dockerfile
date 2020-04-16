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

MAINTAINER Sergi Alvarez "pancake@nopcode.org"

# This is for ARMv5 "legacy" (mipsel) devices which do NOT support hard float
# VFP instructions (mipshf).

# From https://wiki.debian.org/CrossToolchains, installing for jessie
RUN echo "deb http://emdebian.org/tools/debian/ jessie main" > /etc/apt/sources.list.d/emdebian.list \
&& curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - \
&& sed -i 's/httpredir.debian.org/http.debian.net/' /etc/apt/sources.list \
&& dpkg --add-architecture mipsel \
&& apt-get update && apt-get install -y crossbuild-essential-mipsel

# The cross-compiling emulator
RUN dpkg --add-architecture mips64el && \
    apt-get update && \
    apt-get install --yes \
            libelf-dev:mips64el \
            qemu-user \
            qemu-user-static

ENV CROSS_TRIPLE mipsel-linux-gnu
ENV CROSS_ROOT /usr/bin
ENV AS=${CROSS_ROOT}/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_ROOT}/${CROSS_TRIPLE}-cpp-4.9 \
    CXX=${CROSS_ROOT}/${CROSS_TRIPLE}-g++ \
    LD=${CROSS_ROOT}/${CROSS_TRIPLE}-ld \
    FC=${CROSS_ROOT}/${CROSS_TRIPLE}-gfortran

ENV QEMU_LD_PREFIX ${CROSS_ROOT}/libc
ENV QEMU_SET_ENV "LD_LIBRARY_PATH=${CROSS_ROOT}/lib:${CROSS_ROOT}/libc/lib/${CROSS_TRIPLE}/"

COPY Toolchain.cmake ${CROSS_ROOT}/
ENV CMAKE_TOOLCHAIN_FILE ${CROSS_ROOT}/Toolchain.cmake

# Linux kernel cross compilation variables
ENV PATH ${PATH}:${CROSS_ROOT}/bin
ENV CROSS_COMPILE ${CROSS_TRIPLE}-
ENV ARCH mips

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG DOCKCROSS_ORG=dockcross
ARG IMAGE=${DOCKCROSS_ORG}/linux-mipsel
ARG DOCKCROSS_VERSION
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
ENV DEFAULT_DOCKCROSS_IMAGE ${IMAGE}:${VERSION}
