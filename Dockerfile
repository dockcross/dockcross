FROM debian:jessie
MAINTAINER Leigh Phillips "neurocis@neurocis.me"

RUN apt-get update && apt-get -y install \
  automake \
  autogen \
  bash \
  build-essential \
  bzip2 \
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
  xz-utils \
  libboost-all-dev \
  libminiupnpc-dev

# Install BerkeleyDB 5.1, not mainline 5.3.
RUN mkdir libdb5.1 && cd libdb5.1
RUN wget http://ftp.debian.org/debian/pool/main/d/db/libdb5.1_5.1.29-5_amd64.deb && dpkg -i libdb5.1_5.1.29-5_amd64.deb
RUN wget http://ftp.debian.org/debian/pool/main/d/db/libdb5.1++_5.1.29-5_amd64.deb && dpkg -i libdb5.1++_5.1.29-5_amd64.deb
RUN wget http://ftp.debian.org/debian/pool/main/d/db/libdb5.1-dev_5.1.29-5_amd64.deb && dpkg -i libdb5.1-dev_5.1.29-5_amd64.deb
RUN wget http://ftp.debian.org/debian/pool/main/d/db/libdb5.1++-dev_5.1.29-5_amd64.deb && dpkg -i libdb5.1++-dev_5.1.29-5_amd64.deb
RUN cd .. && rm -rf libdb5.1

# Build and install CMake from source.
WORKDIR /usr/src
RUN git clone git://cmake.org/cmake.git CMake && \
  cd CMake && \
  git checkout v3.4.0
RUN mkdir CMake-build
WORKDIR /usr/src/CMake-build
RUN /usr/src/CMake/bootstrap \
    --parallel=$(nproc) \
    --prefix=/usr && \
  make -j$(nproc) && \
  ./bin/cmake -DCMAKE_USE_SYSTEM_CURL:BOOL=ON \
    -DCMAKE_USE_OPENSSL:BOOL=ON . && \
  make install && \
  rm -rf *
WORKDIR /usr/src

# Build and install Ninja from source
RUN git clone https://github.com/martine/ninja.git && \
  cd ninja && \
  git checkout v1.6.0 && \
  python ./configure.py --bootstrap && \
  ./ninja && \
  cp ./ninja /usr/bin/
