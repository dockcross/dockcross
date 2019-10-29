#!/usr/bin/env bash

set -ex

MY_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MY_DIR/utils.sh

#
# Function 'do_curl_build' and 'build_curl'
# copied from https://github.com/pypa/manylinux/tree/master/docker/build_scripts
#

CURL_ROOT=curl_7.52.1
CURL_HASH=a8984e8b20880b621f61a62d95ff3c0763a3152093a9f9ce4287cfd614add6ae

# We had to switch to a debian mirror because we can't use TLS until we
# bootstrap it with this curl + openssl
CURL_DOWNLOAD_URL=http://deb.debian.org/debian/pool/main/c/curl

function do_curl_build {
    # We do this shared to avoid obnoxious linker issues where git couldn't
    # link properly. If anyone wants to make this build statically go for it.
    LIBS="-ldl -lpthread" CFLAGS="-Wl,--exclude-libs,ALL" ./configure --with-ssl --disable-static 2>/dev/null
    make > /dev/null
    make install > /dev/null
}


function build_curl {
    local curl_fname=$1
    check_var ${curl_fname}
    local curl_sha256=$2
    check_var ${curl_sha256}
    check_var ${CURL_DOWNLOAD_URL}
    # Can't use curl here because we don't have it yet...we are building it.
    wget -q ${CURL_DOWNLOAD_URL}/${curl_fname}.orig.tar.gz
    check_sha256sum ${curl_fname}.orig.tar.gz ${curl_sha256}
    tar -zxf ${curl_fname}.orig.tar.gz
    (cd curl-* && do_curl_build)
    rm -rf curl_*
}

cd /usr/src
build_curl $CURL_ROOT $CURL_HASH

(cat /etc/ld.so.conf.d/usr-local.conf 2> /dev/null | grep -q "^/usr/local/lib$") ||
  echo '/usr/local/lib' >> /etc/ld.so.conf.d/usr-local.conf
ldconfig

