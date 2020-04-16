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

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get --yes install \
            gcc-multilib \
            g++-multilib \
            libc6:i386 \
            libelf-dev:i386 \
            libstdc++6:i386 \
            libbz2-dev:i386 \
            libexpat1-dev:i386 \
            ncurses-dev:i386

ENV CROSS_TRIPLE i686-linux-gnu
ENV CROSS_ROOT /usr/${CROSS_TRIPLE}
ENV PATH ${PATH}:${CROSS_ROOT}/bin
RUN mkdir -p ${CROSS_ROOT}/bin
COPY ${CROSS_TRIPLE}.sh ${CROSS_ROOT}/bin/${CROSS_TRIPLE}.sh
COPY ${CROSS_TRIPLE}-as.sh ${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as.sh
COPY ${CROSS_TRIPLE}-noop.sh ${CROSS_ROOT}/bin/${CROSS_TRIPLE}-noop.sh
RUN cd ${CROSS_ROOT}/bin && \
  chmod +x ${CROSS_TRIPLE}.sh && \
  ln -s /usr/bin/x86_64-linux-gnu-gcc && \
  ln -s /usr/bin/x86_64-linux-gnu-g++ && \
  ln -s /usr/bin/x86_64-linux-gnu-as && \
  ln -s ${CROSS_TRIPLE}.sh ${CROSS_TRIPLE}-gcc && \
  ln -s ${CROSS_TRIPLE}.sh ${CROSS_TRIPLE}-g++ && \
  ln -s ${CROSS_TRIPLE}-as.sh ${CROSS_TRIPLE}-as && \
  ln -s /usr/bin/x86_64-linux-gnu-ar ${CROSS_TRIPLE}-ar && \
  ln -s ${CROSS_TRIPLE}-noop.sh ${CROSS_TRIPLE}-noop
ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gcc \
    CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-g++

COPY Toolchain.cmake /usr/lib/${CROSS_TRIPLE}/
ENV CMAKE_TOOLCHAIN_FILE /usr/lib/${CROSS_TRIPLE}/Toolchain.cmake

# Linux kernel cross compilation variables
ENV CROSS_COMPILE ${CROSS_TRIPLE}-
ENV ARCH x86

COPY linux32-entrypoint.sh /dockcross/
ENTRYPOINT ["/dockcross/linux32-entrypoint.sh"]

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG DOCKCROSS_ORG=dockcross
ARG IMAGE=${DOCKCROSS_ORG}/linux-x86
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
