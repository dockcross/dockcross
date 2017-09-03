#!/bin/bash

#
# Configure, build and install OpenSSL
#
# Usage:
#
#  install-openssl.sh [-32]
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

set -e
set -o pipefail

WRAPPER=""
CONFIG_FLAG="-fPIC"
SUFFIX=64

while [ $# -gt 0 ]; do
  case "$1" in
    -32)
      WRAPPER="linux32"
      CONFIG_FLAG="-m32"
      SUFFIX=32
      ;;
    *)
      echo "Usage: Usage: ${0##*/} [-32]"
      exit 1
      ;;
  esac
  shift
done

OPENSSL_VERSION=1.0.2j
OPENSSL_SHA256=e7aff292be21c259c6af26469c7a9b3ba26e9abaaffd325e3dccc9785256c431

cd /usr/src

# Download
if [ ! -f ./openssl-$OPENSSL_VERSION.tar.gz ]; then
  wget --progress=bar:force https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
else
  rm -rf ./openssl-$OPENSSL_VERSION
fi

# Verify
sha256_openssl=`sha256sum ./openssl-$OPENSSL_VERSION.tar.gz | awk '{ print $1 }'`
if [ "$sha256_openssl" != "$OPENSSL_SHA256" ]
then
  echo "SHA256 mismatch. Problem downloading OpenSSL."
  echo "  current [$sha256_openssl]"
  echo "  expected[$OPENSSL_SHA256]"
  exit 1
fi

# Extract
tar -xzvf openssl-$OPENSSL_VERSION.tar.gz

pushd openssl-$OPENSSL_VERSION

# Configure
${WRAPPER} ./config --prefix=/usr $CONFIG_FLAG

# Build & Install
${WRAPPER} make install

popd

# Clean
rm -rf ./openssl-$OPENSSL_VERSION*
rm -rf /usr/ssl/man

