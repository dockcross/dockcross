#!/bin/bash

# AUTHOR: odidev
# DATE: 2021-07-20
# DESCRIPTION: This file will be invoked by cibuildwheel when before all is set.
#              It will install the package in manylinux container and copy back
#              the installed files on host machine will will be coppied to
#              toolchain

install_dir='/host/tmp/install_deps'
packages=$(echo $1 | sed 's/\(yum\s*\|install\s*\|-y\s*\)//g')

# Installing the packages
echo "Installing dependencies: $packages"
if $1; then
  echo "Installed successfully"
else
  echo "Failed"
  exit 1
fi

# Coping the installed files
if list=`rpm -ql $packages`; then

  echo "Copying dependencies files to prepare cross toolchain-"

  for file in $list; do
    test -f $file && echo "Copy $file --> ${install_dir}${file}"
    test -f $file && install -m 0644 -D $file "${install_dir}${file}"
  done
else
  echo $list
  echo "Dependencies not resolved"
  exit 1
fi
exit 0
