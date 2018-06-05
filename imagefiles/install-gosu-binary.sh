#!/bin/bash

set -ex

if ! command -v curl &> /dev/null; then
	echo >&2 'error: "curl" not found!'
	exit 1
fi

if ! command -v gpg &> /dev/null; then
	echo >&2 'error: "gpg" not found!'
	exit 1
fi

GOSU_VERSION=1.10
dpkgArch=$(if test $(uname -m) = "x86_64"; then echo amd64; else echo i386; fi)
url="https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}"
url_key="https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}.asc"

# download and verify the signature
export GNUPGHOME="$(mktemp -d)"

gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

echo "Downloading $url"
curl -o /usr/local/bin/gosu -# -SL $url

echo "Downloading $url_key"
curl -o /usr/local/bin/gosu.asc -# -SL $url_key

gpg --verify /usr/local/bin/gosu.asc

# cleanup
rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc

chmod +x /usr/local/bin/gosu

# verify that the binary works
gosu nobody true
