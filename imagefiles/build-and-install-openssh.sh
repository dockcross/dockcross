#!/usr/bin/env bash

set -ex

OPENSSH_ROOT=V_8_7_P1

cd /usr/src
curl --connect-timeout 20 \
    --max-time 10 \
    --retry 5 \
    --retry-delay 10 \
    --retry-max-time 40 \
    -LO https://github.com/openssh/openssh-portable/archive/${OPENSSH_ROOT}.tar.gz

tar -xvf ${OPENSSH_ROOT}.tar.gz
rm -f ${OPENSSH_ROOT}.tar.gz

OPENSSH_SRC_DIR=openssh-portable-${OPENSSH_ROOT}
cd ${OPENSSH_SRC_DIR}

autoreconf

./configure --with-ssl-dir=/usr/local/ssl --prefix=/usr/local --with-libs=-lpthread


make -j"$(nproc)"
make install

cd /usr/src
rm -rf ${OPENSSH_SRC_DIR}
