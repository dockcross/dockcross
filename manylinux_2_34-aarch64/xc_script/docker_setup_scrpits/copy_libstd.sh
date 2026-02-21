#!/bin/bash

# AUTHOR: odidev
# DATE: 2021-07-20
# DESCRIPTION: This file is invoked two times. first time from Makefile with
#              PASS == 1 and second time in Dockerfile.in with PASS == 2. In
#              dockcross container, the current libstdc++ is not the same as
#              in manylinux containers. So, copying the libstdc++ form manylinux
#              container to dockcross container. It is being done int 2 pass.
#              during PASS == 1, the script will copy libstdc++ from manylinux
#              container to build machine and then during PASS == 2, libstdc++
#              will be copied from build machine to dockcross container

if [ $PASS == 1 ]; then
    echo "library location on host: " ${LIB_PATH}
    echo "PASS 1: copying libstdc++ library on host"
    files=$(rpm -ql libstdc++)
    for file in ${files}; do
        if [ -f ${file} -a ! -L ${file} -a ! -d ${file} ]; then
            if grep -q "shared object" <<< $(file $file); then
		install -m 0644 -D ${file} "${LIB_PATH}${file}"
                break;
            fi
        fi
    done
    echo "Done"
elif [ $PASS == 2 ]; then
    echo "PASS 2: copying libstdc++ library in docker image"
    old_libstdc_path=$(find /usr/xcc/ -name libstdc++.so*[0-9] -type f)
    old_libstdc_directory=$(dirname "${old_libstdc_path}")
    target_libstdc_path=$(find /tmp -name libstdc++.so*[0-9] -type f)
    target_libstdc_filename=$(basename "${target_libstdc_path}")
    target_libstdc_new_path=${old_libstdc_directory}/${target_libstdc_filename}
    install -m 0555 -D ${target_libstdc_path} ${target_libstdc_new_path}
    echo "Done"
    links=$(find /usr/xcc/ \( -name libstdc++.so*[{0-9}] -o -name libstdc++.so \) -type l)
    echo "Creating soft links for target libstdc++ library"
    for link in ${links}; do
	case "$link" in
            (*libstdc++.so*[{0-9}].[{0-9}].[{0-9}]*)
                target_libstdc_filename=$(basename "${target_libstdc_new_path}")
                libstdc_link_directory=$(dirname "${link}")
		rm -rf $link
		target_libstdc_link_path=${libstdc_link_directory}/${target_libstdc_filename}
                ln -sf ${target_libstdc_new_path} ${target_libstdc_link_path}
                ;;
            (*)
                ln -sf ${target_libstdc_new_path} ${link}
        esac
    done
    echo "Done"
fi
