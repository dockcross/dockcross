#!/bin/bash

#
# Configure, build and install CMake
#
# Usage:
#
#  install-cmake.sh [-32]
#
# Options:
#
#  -32                 Build CMake as a 32-bit executable
#
# Notes:
#
#  * build directory is /usr/src/CMake
#
#  * install directory is /usr
#
#  * after installation, archive, source and build directories are removed
#

set -e
set -o pipefail

WRAPPER=""
CONFIG_FLAG=""
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

cd /usr/src

# Download
CMAKE_REV=v3.10.1
curl -# -o CMake.tar.gz -LO https://github.com/kitware/cmake/archive/$CMAKE_REV.tar.gz
mkdir CMake
tar -xzvf ./CMake.tar.gz --strip-components=1 -C ./CMake

mkdir /usr/src/CMake-build

pushd /usr/src/CMake-build

NUM_PROCESSOR=$(grep -c processor /proc/cpuinfo)

# Configure boostrap
${WRAPPER} /usr/src/CMake/bootstrap \
  --parallel=$NUM_PROCESSOR \
  --prefix=/usr

# Build and Install
${WRAPPER} make install -j$NUM_PROCESSOR

# Test
ctest -R CMake.FileDownload

# Write test script
cat <<EOF > cmake-test-https-download.cmake

file(
  DOWNLOAD https://raw.githubusercontent.com/Kitware/CMake/master/README.rst /tmp/README.rst
  STATUS status
  )
list(GET status 0 error_code)
list(GET status 1 error_msg)
if(error_code)
  message(FATAL_ERROR "error: Failed to download ${url} - ${error_msg}")
else()
  message(STATUS "CMake: HTTPS download works")
endif()

file(REMOVE /tmp/README.rst)

EOF

# Execute test script
cmake -P cmake-test-https-download.cmake
rm cmake-test-https-download.cmake

popd

rm -rf CMake*
