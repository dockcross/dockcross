FROM dockcross/base
MAINTAINER Roman Valls Guimera "brainstorm@nopcode.org"

# For embedded IoT systems such as the ESP82xx from Espressif

RUN echo "deb http://ftp.de.debian.org/debian jessie main non-free" > /etc/apt/sources.list.d/non-free.list \
&& apt-get update && apt-get install -y \
  qemu-user \
  qemu-user-static \
	autoconf \
	automake \
	bison \
	bzip2 \
	flex \
	g++ \
	gawk \
	gcc \
	git \
	gperf \
	libexpat-dev \
	libtool \
	libtool-bin \
	make \
	ncurses-dev \
	nano \
	python \
	python-dev \
	python-serial \
	sed \
	texinfo \
	rar \
	unzip \
	wget \
	help2man \
	git \
&& apt-get clean

RUN useradd -ms /bin/bash espbuild
USER espbuild
WORKDIR /home/espbuild
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git && cd esp-open-sdk && make

ENV PATH=/home/espbuild/esp-open-sdk/xtensa-lx106-elf/bin:$PATH

ENV CROSS_TRIPLE xtensa-lx106-elf
ENV CROSS_ROOT /home/espbuild/esp-open-sdk/xtensa-lx106-elf/bin
ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-g++ \
    LD=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ld

ENV QEMU_LD_PREFIX ${CROSS_ROOT}/libc
ENV QEMU_SET_ENV "LD_LIBRARY_PATH=${CROSS_ROOT}/lib:${CROSS_ROOT}/libc/lib/${CROSS_ROOT}/"

ENV DEFAULT_DOCKCROSS_IMAGE brainstorm/dockcross-esp-open-sdk
