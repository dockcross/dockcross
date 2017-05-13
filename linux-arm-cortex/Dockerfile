FROM dockcross/base:latest
MAINTAINER Declan Zhang <deqzhang@ucdavis.edu>

# Download and install cross-compiler binaries
RUN wget --progress=bar:force https://developer.arm.com/-/media/Files/downloads/gnu-rm/6_1-2017q1/gcc-arm-none-eabi-6-2017-q1-update-linux.tar.bz2 \ 
  && tar -jxf gcc-arm-none-eabi-6-2017-q1-update-linux.tar.bz2 -C /opt \
  && rm -rf gcc-arm-none-eabi-6-2017-q1-update-linux.tar.bz2

RUN apt-get update && apt-get install -y \
  qemu-user \
  qemu-user-static

ENV CROSS_TRIPLE arm-none-eabi
ENV CROSS_ROOT /opt/gcc-${CROSS_TRIPLE}-6-2017-q1-update/bin
ENV AS=${CROSS_ROOT}/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}//${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_ROOT}/${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_ROOT}/${CROSS_TRIPLE}-g++ \
    LD=${CROSS_ROOT}/${CROSS_TRIPLE}-ld

ENV DEFAULT_DOCKCROSS_IMAGE dockcross/linux-arm-cortex

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
