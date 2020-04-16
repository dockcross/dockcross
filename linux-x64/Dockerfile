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

RUN apt-get update && \
    apt-get --yes install \
            libelf-dev

ENV CROSS_TRIPLE x86_64-linux-gnu
ENV CROSS_ROOT /usr/bin
ENV AS=/usr/bin/${CROSS_TRIPLE}-as \
    AR=/usr/bin/${CROSS_TRIPLE}-ar \
    CC=/usr/bin/${CROSS_TRIPLE}-gcc \
    CPP=/usr/bin/${CROSS_TRIPLE}-cpp \
    CXX=/usr/bin/${CROSS_TRIPLE}-g++ \
    LD=/usr/bin/${CROSS_TRIPLE}-ld \
    FC=/usr/bin/${CROSS_TRIPLE}-gfortran

COPY ${CROSS_TRIPLE}-noop.sh /usr/bin/${CROSS_TRIPLE}-noop

COPY Toolchain.cmake /usr/lib/${CROSS_TRIPLE}/
ENV CMAKE_TOOLCHAIN_FILE /usr/lib/${CROSS_TRIPLE}/Toolchain.cmake

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG DOCKCROSS_ORG=dockcross
ARG IMAGE=${DOCKCROSS_ORG}/linux-x64
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
