#!/bin/bash

#
# Configure, build and install ninja
#
# Usage:
#
#  install-ninja.sh [-python /path/to/bin/python]

set -e
set -o pipefail

PYTHON=python
while [ $# -gt 0 ]; do
  case "$1" in
    -python)
      PYTHON=$2
      shift
      ;;
    *)
      echo "Usage: Usage: ${0##*/} [-python /path/to/bin/python]"
      exit 1
      ;;
  esac
  shift
done

# Download
REV=v1.7.2
curl -# -o ninja.tar.gz -LO https://github.com/ninja-build/ninja/archive/$REV.tar.gz
mkdir ninja
tar -xzvf ./ninja.tar.gz --strip-components=1 -C ./ninja

# Configure, build and install
pushd ./ninja
echo "Configuring ninja using [$PYTHON]"
$PYTHON ./configure.py --bootstrap && ./ninja
cp ./ninja /usr/bin/
popd

# Clean
rm -rf ./ninja*

