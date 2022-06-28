#!/usr/bin/env bash

if (( $# >= 2 )); then
    image_complet=$1
    image=${image_complet%:*}
    tag=${image_complet#*:}
    shift 1

    command=$*
    echo "command: $command"

#    echo "Pulling dockcross/$image"
#    docker pull "dockcross/$image:$tag"

    echo "Make script dockcross-$image"
    docker run --pull never --rm dockcross/"$image" > ./dockcross-"$image"
    chmod +x ./dockcross-"$image"
    
    echo "Run command in dockcross-$image"
    ./dockcross-"$image" $command
else
    echo "Usage: ${0##*/} <docker imag (ex: linux-x64/linux-x64-clang/linux-arm64/windows-shared-x64/windows-static-x64...)> <command>"
    exit 1
fi
