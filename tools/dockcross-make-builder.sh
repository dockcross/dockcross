#!/usr/bin/env bash

if (( $# >= 1 )); then
    image_complet=$1
    image=${image_complet%:*}
    tag=${image_complet#*:}
    build_file=build-$image
    shift 1

    make_arg=$*
    echo "make arg: $make_arg"

#    echo "Pulling dockcross/$image"
#    docker pull "dockcross/$image:$tag"

    echo "Make script dockcross-$image"
    docker run --pull never --rm dockcross/"$image" > ./dockcross-"$image"
    chmod +x ./dockcross-"$image"

    echo "Build $build_file"
    ./dockcross-"$image" bash -c 'make CXX=${CXX} CC=${CC} AR=${AR} AS=${AS} LD=${LD} CPP=${CPP} FC=${FC} '"$make_arg"
else
    echo "Usage: ${0##*/} <docker image (ex: linux-x64/linux-x64-clang/linux-arm64/windows-shared-x64/windows-static-x64...)> <make arg.>"
    exit 1
fi
