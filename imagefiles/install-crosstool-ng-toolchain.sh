#!/usr/bin/env bash

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

usage() { echo "Usage: $0 -p <prefix> -c <config-path> -v <version>" 1>&2; exit 1; }

# Resolve our input parameters.
#
# Note: we use "readlink" to resolve them to absolute paths so we can freelhy
# change directories during installation.
CT_PREFIX=
CONFIG_PATH=
REV=
while getopts "p:c:v:" o; do
  case "${o}" in
  p)
    CT_PREFIX=$(readlink -f ${OPTARG})
    ;;
  c)
    CONFIG_PATH=$(readlink -f ${OPTARG})
    ;;
  v)
    REV=${OPTARG}
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

if [ -z ${REV} ]; then
  echo "WARNING: No version selected, use default version: crosstool-ng-1.23.0 (-v)."
  REV=crosstool-ng-1.23.0
fi


##
# Build "crosstool-ng".
##

CTNG=${ROOT}/ct-ng
mkdir -p "${CTNG}"
cd "${CTNG}"

# Download and install the "crosstool-ng" source.

git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
git fetch --tags

# checkout 
git checkout ${REV}

if [ ${REV} = "crosstool-ng-1.23.0" ]; then
  patch scripts/build/companion_libs/210-expat.sh -i /dockcross/crosstool-ng-expat.patch
  # Patch to fix error with bash 5 and up: https://github.com/pfalcon/esp-open-sdk/issues/365
  patch configure.ac -i /dockcross/Fix-error-with-bash-5-and-up.patch
  # Clean patch
  rm /dockcross/Fix-error-with-bash-5-and-up.patch
  rm /dockcross/crosstool-ng-expat.patch
fi

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


# As mentioned in ct-ng config, need to unset LD_LIBRARY_PATH.
unset LD_LIBRARY_PATH
# Fix build error on manylinux2014-aarch64
unset CC
unset CXX

# Build and install the toolchain!
# Print last 250 lines if build fail
"${BOOTSTRAP_PREFIX}/bin/ct-ng" build || (tail -250 build.log && exit 1)

