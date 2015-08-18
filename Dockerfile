FROM debian:jessie
MAINTAINER Matt McCormick "matt.mccormick@kitware.com"

RUN apt-get update && apt-get -y install \
  automake \
  autogen \
  bash \
  build-essential \
  bzip2 \
  ca-certificates \
  curl \
  file \
  git \
  gzip \
  libcurl4-openssl-dev \
  libssl-dev \
  make \
  ncurses-dev \
  pkg-config \
  python \
  rsync \
  sed \
  tar \
  vim \
  wget \
  xz-utils && \
  apt-get -y clean

# Build and install CMake from source.
WORKDIR /usr/src
RUN git clone git://cmake.org/cmake.git CMake && \
  cd CMake && \
  git checkout v3.4.3 && \
  cd .. && mkdir CMake-build && cd CMake-build && \
  /usr/src/CMake/bootstrap \
    --parallel=$(nproc) \
    --prefix=/usr && \
  make -j$(nproc) && \
  ./bin/cmake -DCMAKE_USE_SYSTEM_CURL:BOOL=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_USE_OPENSSL:BOOL=ON . && \
  make install && \
  cd .. && \
  rm -rf CMake*

# Build and install Ninja from source
RUN git clone https://github.com/martine/ninja.git && \
  cd ninja && \
  git checkout v1.6.0 && \
  python ./configure.py --bootstrap && \
  ./ninja && \
  cp ./ninja /usr/bin/ && \
  cd .. && rm -rf ninja

WORKDIR /build
ENTRYPOINT ["/dockcross/entrypoint.sh"]

COPY imagefiles/entrypoint.sh imagefiles/dockcross /dockcross/
