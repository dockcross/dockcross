FROM dockcross/base:latest
MAINTAINER Matt McCormick "matt.mccormick@kitware.com"

RUN dpkg --add-architecture i386 && \
  apt-get update && apt-get -y install \
    sudo \
    gcc-multilib \
    g++-multilib \
    libc6:i386 \
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


COPY imagefiles/install-openssl.sh /dockcross/
RUN \
  /dockcross/install-openssl.sh -32 && \
  rm /dockcross/install-openssl.sh

ENV DEFAULT_DOCKCROSS_IMAGE dockcross/linux-x86

# Note: Toolchain file support is currently in debian Experimental:
# https://wiki.debian.org/CrossToolchains#In_jessie_.28Debian_8.29
COPY Toolchain.cmake /usr/lib/${CROSS_TRIPLE}/
ENV CMAKE_TOOLCHAIN_FILE /usr/lib/${CROSS_TRIPLE}/Toolchain.cmake

COPY linux32-entrypoint.sh /dockcross/
ENTRYPOINT ["/dockcross/linux32-entrypoint.sh"]

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
