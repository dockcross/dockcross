#!/usr/bin/env bash

set -ex

if ! command -v curl &> /dev/null; then
	echo >&2 'error: "curl" not found!'
	exit 1
fi

if ! command -v tar &> /dev/null; then
	echo >&2 'error: "tar" not found!'
	exit 1
fi

if [[ -z "${GIT_VERSION}" ]]; then
  echo >&2 'error: GIT_VERSION env. variable must be set to a non-empty value'
  exit 1
fi

(cat /etc/ld.so.conf.d/usr-local.conf 2> /dev/null | grep -q "^/usr/local/lib$") ||
  echo '/usr/local/lib' >> /etc/ld.so.conf.d/usr-local.conf
ldconfig

cd /usr/src

url="https://mirrors.edge.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz"
echo "Downloading $url"
curl --connect-timeout 20 \
    --max-time 300 \
    --retry 5 \
    --retry-delay 10 \
    --retry-max-time 300 \
    -# -LO $url

tar xvzf "git-${GIT_VERSION}.tar.gz" --no-same-owner
rm -f "git-${GIT_VERSION}.tar.gz"

pushd "git-${GIT_VERSION}"
./configure --prefix=/usr/local --with-curl
make -j"$(nproc)"
make install
popd

ldconfig

rm -rf "git-${GIT_VERSION}"

# turn the detached message off
git config --global advice.detachedHead false
