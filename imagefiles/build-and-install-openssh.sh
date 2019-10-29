#!/usr/bin/env bash

set -ex

OPENSSH_ROOT=V_8_1_P1

cd /usr/src
curl -LO https://github.com/openssh/openssh-portable/archive/${OPENSSH_ROOT}.tar.gz
tar -xvf ${OPENSSH_ROOT}.tar.gz
rm -f ${OPENSSH_ROOT}.tar.gz

OPENSSH_SRC_DIR=openssh-portable-${OPENSSH_ROOT}
cd ${OPENSSH_SRC_DIR}

autoreconf

LDFLAGS="-pthread" \
./configure --with-ssl-dir=/usr/local/ssl --prefix=/usr/local

make -j1 install

cd /usr/src
rm -rf ${OPENSSH_SRC_DIR}
