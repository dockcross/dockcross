FROM dockcross/base:latest
MAINTAINER Declan Zhang <deqzhang@ucdavis.edu>

# Download and install cross-compiler binaries
RUN wget https://releases.linaro.org/components/toolchain/binaries/latest/arm-eabi/gcc-linaro-6.3.1-2017.02-x86_64_arm-eabi.tar.xz
RUN wget https://releases.linaro.org/components/toolchain/binaries/latest/aarch64-elf/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-elf.tar.xz
RUN apt-get update && apt-get install -y qemu-user qemu-user-static libpython-dev

RUN mkdir -p /opt/linaro/
RUN tar xf gcc-linaro-6.3.1-2017.02-x86_64_arm-eabi.tar.xz -C /opt/linaro/
RUN tar xf gcc-linaro-6.3.1-2017.02-x86_64_aarch64-elf.tar.xz -C /opt/linaro/
RUN rm -f gcc-linaro-6.3.1-2017.02-x86_64_arm-eabi.tar.xz gcc-linaro-6.3.1-2017.02-x86_64_aarch64-elf.tar.xz

ENV CROSS_TRIPLE arm-eabi
ENV CROSS_PATH /opt/linaro/gcc-linaro-6.3.1-2017.02-x86_64_arm-eabi
ENV CROSS_ROOT ${CROSS_PATH}/bin
ENV AS=${CROSS_ROOT}/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}//${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_ROOT}/${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_ROOT}/${CROSS_TRIPLE}-g++ \
    LD=${CROSS_ROOT}/${CROSS_TRIPLE}-ld
ENV PATH=$PATH:${CROSS_ROOT}
ENV DEFAULT_DOCKCROSS_IMAGE dockcross/linux-arm-cortex

COPY Toolchain.cmake ${CROSS_ROOT}
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
