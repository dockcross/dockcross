#!/usr/bin/env bash
#
# Configure, build and install OpenSSL
#
# Usage:
#
#  build-and-install-openssl.sh [-32]
#
# Options:
#
#  -32              Build OpenSSL as a 32-bit library
#
# Notes:
#
#  * build directory is /usr/src/openssl-$OPENSSL_VERSION
#
#  * install directory is /usr
#
#  * after installation, build directory and archive are removed
#

set -ex
set -o pipefail

WRAPPER=""
CONFIG_FLAG=""

while [ $# -gt 0 ]; do
  case "$1" in
    -32)
      WRAPPER="linux32"
      CONFIG_FLAG="-m32"
      ;;
    *)
      echo "Usage: Usage: ${0##*/} [-32]"
      exit 1
      ;;
  esac
  shift
done

MY_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MY_DIR/utils.sh

#
# Function 'do_openssl_build' and 'build_openssl'
# copied from https://github.com/pypa/manylinux/tree/master/docker/build_scripts
#

if [[ -z "${OPENSSL_VERSION}" ]]; then
  echo >&2 'error: OPENSSL_VERSION env. variable must be set to a non-empty value'
  exit 1
fi

if [[ -z "${OPENSSL_HASH}" ]]; then
  echo >&2 'error: OPENSSL_HASH env. variable must be set to a non-empty value'
  exit 1
fi

if [[ -z "${PERL_VERSION}" ]]; then
  echo >&2 'error: PERL_VERSION env. variable must be set to a non-empty value'
  exit 1
fi

if [[ -z "${PERL_HASH}" ]]; then
  echo >&2 'error: PERL_HASH env. variable must be set to a non-empty value'
  exit 1
fi

# Hash from https://www.openssl.org/source/openssl-1.1.1w.tar.gz.sha256
OPENSSL_DOWNLOAD_URL=http://www.openssl.org/source/

PERL_DOWNLOAD_URL=https://www.cpan.org/src/5.0

function do_perl_build {
    ${WRAPPER} sh Configure -des -Dprefix=/opt/perl > /dev/null
    ${WRAPPER} make -j"$(nproc)" > /dev/null
    ${WRAPPER} make install > /dev/null
}

function build_perl {
    local perl_fname=$1
    check_var ${perl_fname}
    local perl_sha256=$2
    check_var ${perl_sha256}
    check_var ${PERL_DOWNLOAD_URL}
    curl --connect-timeout 30 \
        --max-time 10 \
        --retry 5 \
        --retry-delay 10 \
        --retry-max-time 30 \
        -fsSLO ${PERL_DOWNLOAD_URL}/${perl_fname}.tar.gz

    check_sha256sum ${perl_fname}.tar.gz ${perl_sha256}
    tar -xzf ${perl_fname}.tar.gz --no-same-owner
    (cd ${perl_fname} && do_perl_build)
    rm -rf ${perl_fname} ${perl_fname}.tar.gz
}

function do_openssl_build {
    ${WRAPPER} ./config no-shared -fPIC $CONFIG_FLAG --prefix=/usr/local/ssl --openssldir=/usr/local/ssl > /dev/null
    ${WRAPPER} make -j"$(nproc)" > /dev/null
    ${WRAPPER} make install_sw > /dev/null
}

function build_openssl {
    local openssl_fname=$1
    check_var ${openssl_fname}
    local openssl_sha256=$2
    check_var ${openssl_sha256}
    check_var ${OPENSSL_DOWNLOAD_URL}
    curl --connect-timeout 30 \
        --max-time 10 \
        --retry 5 \
        --retry-delay 10 \
        --retry-max-time 30 \
        -fsSLO ${OPENSSL_DOWNLOAD_URL}/${openssl_fname}.tar.gz

    check_sha256sum ${openssl_fname}.tar.gz ${openssl_sha256}
    tar -xzf ${openssl_fname}.tar.gz
    (cd ${openssl_fname} && PATH=/opt/perl/bin:${PATH} do_openssl_build)
    rm -rf ${openssl_fname} ${openssl_fname}.tar.gz
    # Cleanup install tree
    rm -rf /usr/ssl/man
}

cd /usr/src
build_perl "${PERL_VERSION}" "${PERL_HASH}"
build_openssl "${OPENSSL_VERSION}" "${OPENSSL_HASH}"

# Delete PERL
rm -rf /opt/perl
