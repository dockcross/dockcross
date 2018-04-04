#!/bin/bash

# This script operates in a current working directory. It downloads
# "crosstool-ng", installs the base package, and then configures and installs
# a toolchain based on the supplied prefix and configuration.
#
# Artifacts:
# - "crosstool-ng" data in the current working directory (can be deleted).
# - Configured Toolchain installed in the supplied <prefix>.

set -x
set -e
set -o pipefail

# Our base directory is the current working directory. All local artifacts will
# be generated underneath of here.
ROOT=${PWD}

usage() { echo "Usage: $0 -p <prefix> -c <config-path>" 1>&2; exit 1; }

# Resolve our input parameters.
#
# Note: we use "readlink" to resolve them to absolute paths so we can freelhy
# change directories during installation.
CT_PREFIX=
CONFIG_PATH=
while getopts "p:c:" o; do
  case "${o}" in
  p)
    CT_PREFIX=$(readlink -f ${OPTARG})
    ;;
  c)
    CONFIG_PATH=$(readlink -f ${OPTARG})
    ;;
  *)
    usage
    ;;
  esac
done
shift $((OPTIND-1))

if [ -z ${CT_PREFIX} ]; then
  echo "ERROR: You must supply an installation prefix (-p)."
  usage
fi
if [ -z ${CONFIG_PATH} ] || [ ! -f ${CONFIG_PATH} ]; then
  echo "ERROR: Missing config path (-c)."
  usage
fi

##
# Build "crosstool-ng".
##

CTNG=${ROOT}/ct-ng
mkdir -p "${CTNG}"
cd "${CTNG}"

# Download and install the "crosstool-ng" source.
REV=1.23.0
curl -# -LO \
  "https://github.com/crosstool-ng/crosstool-ng/archive/crosstool-ng-${REV}.tar.gz"
tar -xf "crosstool-ng-${REV}.tar.gz"
cd "crosstool-ng-crosstool-ng-${REV}"

# Bootstrap and install the tool.
BOOTSTRAP_PREFIX="${CTNG}/prefix"
./bootstrap
./configure \
  --prefix "${BOOTSTRAP_PREFIX}"
make -j$(nproc)
make install

##
# Use "crosstool-ng" to build the toolchain.
##

# Override installation prefix, since we want to define it externally.
export CT_PREFIX

# Allow installation as root, since we aren't really worried about system
# damage b/c we're running in a container and this saves us the trouble of
# having to generate a crosstool user.
export CT_ALLOW_BUILD_AS_ROOT_SURE=1

# Create our build directory and copy our configuration into it.
BUILD="${ROOT}/toolchain"
mkdir -p "${BUILD}"
cd "${BUILD}"

cp "${CONFIG_PATH}" "${BUILD}/.config"

# Build and install the toolchain!
"${BOOTSTRAP_PREFIX}/bin/ct-ng" build
