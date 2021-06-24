#!/usr/bin/env bash

#
# Configure, build and install python
#
# Usage:
#
#  build-and-install-python.sh [-version 3.9.5]
# needed packages : libncurses5-dev libgdbm-dev libnss3-dev 
#   libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev

PYTHON_VERSION=3.9.5
while [ $# -gt 0 ]; do
  case "$1" in
    -version|-v)
      PYTHON_VERSION=$2
      shift
      ;;&
    *)
      echo "Usage: Usage: ${0##*/} [-version 3.9.5]"
      exit 1
      ;;
  esac
  shift
done

# Download
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar xvf Python-${PYTHON_VERSION}.tgz
# Configure, build and install
cd Python-${PYTHON_VERSION}
# Disable --enable-shared --enable-optimizations --prefix=/usr/local/python-${PYTHON_VERSION}
./configure --with-ensurepip=install
make -j$(nproc) 
make install #altinstall

ln -s /usr/local/bin/python3 /usr/local/bin/python
ln -s /usr/local/bin/pip3 /usr/local/bin/pip

# Clean
cd ..
rm -rf Python-${PYTHON_VERSION}
