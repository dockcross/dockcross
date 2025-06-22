#!/usr/bin/env bash
set -x
set -e
set -o pipefail

ROOT=${PWD}

usage() { echo "Usage: $0 -c <config-path> -v <version>" 1>&2; exit 1; }

REPO_URL="https://github.com/buildroot/buildroot.git"

CONFIG_PATH=""
REV="2025.05"
while getopts "c:v:" o; do
  case "${o}" in
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

if [ -z ${CONFIG_PATH} ] || [ ! -f ${CONFIG_PATH} ]; then
  echo "ERROR: Missing config path (-c)."
  usage
fi

if [ -z ${REV} ]; then
  echo "WARNING: No version selected, use default version: $REV (-v)."
fi

git clone "$REPO_URL" --recurse-submodules --shallow-submodules --depth 1 --branch "$REV" buildroot
# Only to generate the project files, config will be overwritten later
make -C buildroot O=/aarch64_efi aarch64_efi_defconfig
cp "$CONFIG_PATH" /aarch64_efi/.config
FORCE_UNSAFE_CONFIGURE=1 make -C /aarch64_efi sdk
rm -rf buildroot /aarch64_efi/build /aarch64_efi/images /aarch64_efi/staging /aarch64_efi/target/
