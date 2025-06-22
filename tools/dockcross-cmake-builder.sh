#!/usr/bin/env bash

set -x

if (( $# >= 1 )); then
    image_complete=$1
    image=${image_complete%:*}
    tag=${image_complete#*:}
    build_file=build-$image
    host_arch=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
    if test $tag = $image; then
        # use multiarch image if available
        if docker images | grep dockcross/${image} | grep latest-${host_arch} >/dev/null; then
          tag="latest-${host_arch}"
        else
          tag="latest"
        fi
    fi
    shift 1

    cmake_arg=$*
    echo "cmake arg: $cmake_arg"
    
    echo "Make script dockcross-$image"
    docker run --rm dockcross/"$image:$tag" > ./dockcross-"$image"
    chmod +x ./dockcross-"$image"

    echo "Build $build_file"
    ./dockcross-"$image" -i dockcross/"$image:$tag" cmake -B "$build_file" -S . -G Ninja $cmake_arg
    ./dockcross-"$image" -i dockcross/"$image:$tag" ninja -C "$build_file"
else
    echo "Usage: ${0##*/} <docker image (ex: linux-x64/linux-x64-clang/linux-arm64/windows-shared-x64/windows-static-x64...)> <cmake arg.>"
    exit 1
fi
