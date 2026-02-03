#!/bin/bash

# AUTHOR: odidev
# DATE: 2021-07-20
# DESCRIPTION: This file intended to cross compile the python and create necessary
#              crossenv enrironment

# The current env is not compatible to build python so resetting it as
# in quay.io/pypa/manylinux2014_x86_64 containers
unset $(env | awk -F= '{print $1}')
export SSL_CERT_FILE=/opt/_internal/certs.pem
export TERM=xterm
export LC_ALL=en_US.UTF-8
export LD_LIBRARY_PATH=/opt/rh/gcc-toolset-14/root/usr/lib64:/opt/rh/gcc-toolset-14/root/usr/lib:/opt/rh/gcc-toolset-14/root/usr/lib64/dyninst:/opt/rh/gcc-toolset-14/root/usr/lib/dyninst:/usr/local/lib64
export PATH=/opt/rh/gcc-toolset-14/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PWD=/work
export LANG=en_US.UTF-8
export AUDITWHEEL_ARCH=x86_64
export DEVTOOLSET_ROOTPATH=/opt/rh/gcc-toolset-14/root
export HOME=/root
export SHLVL=1
export LANGUAGE=en_US.UTF-8
export AUDITWHEEL_PLAT=manylinux_2_34_aarch64
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export AUDITWHEEL_POLICY=manylinux_2_34

# Cross compile Python versions present in manylinux containers
declare -A buildpy
python_vers=""

for PY in /opt/python/cp*/bin/python; do
    ver=`$PY --version | cut -d " " -f 2`
    python_vers="${python_vers} ${ver}"
    cpver=cp`echo ${ver} | cut -d "." -f 1-2 | sed 's/\.//'`
    if [ ${cpver} = "cp36" ] || [ ${cpver} = "cp37" ]; then
        cpver="${cpver}-${cpver}m"
    else
        cpver="${cpver}-${cpver}"
    fi
    buildpy[${ver}]=${cpver}
done


# Adding cross compiler path in PATH env variable
export PATH=/usr/xcc/aarch64-unknown-linux-gnu/bin:$PATH

OLD_PATH=$PATH
CROSS_PY_BASE=/opt/_internal
CROSS_PY_BASE_LN=/opt/python
BUILD_DIR=/tmp/builds
LN=ln
sub_rel=""

# Loop over each python version and cross compile it
for python_ver in $python_vers; do
    rel=""
    sub_rel=""
    found_sub_rel=0
    for i in ` seq ${#python_ver}`
    do
        c=${python_ver:$i-1:1}
        if [[ ${c} == [a-zA-Z] ]] ; then
            found_sub_rel=1
        fi
        if [[ $found_sub_rel == "0" ]]; then
            rel=${rel}${c}
        else
            sub_rel=${sub_rel}${c}
        fi
    done

    mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}
    wget https://www.python.org/ftp/python/${rel}/Python-${rel}${sub_rel}.tgz
    tar xzf Python-${rel}${sub_rel}.tgz
    cd Python-${rel}${sub_rel}

    # Setting up build python path required by crassenv
    BUILD_PYBIN=${CROSS_PY_BASE_LN}/${buildpy[$python_ver]}/bin
    BUILD_PIP=${BUILD_PYBIN}/pip3
    BUILD_PYTHON=${BUILD_PYBIN}/python3

    # Setting up target python required by crossenv
    TARGET_PYPATH=${CROSS_PY_BASE}/xc/xcpython-${python_ver}
    TARGET_PYTHON=${TARGET_PYPATH}/bin/python3

    # Setting up cross env path
    CROSS_ENV=${CROSS_PY_BASE}/${buildpy[$python_ver]}-xc
    CROSS_ENV_LN=${CROSS_PY_BASE_LN}/${buildpy[$python_ver]}-xc
    CROSS_ENV_PIP=${CROSS_ENV_LN}/cross/bin/pip

    # Adding build python path as it is required to
    # configure the python for cross compilation
    PATH=${BUILD_PYBIN}:${OLD_PATH}
    export PATH

    ./configure --prefix=${TARGET_PYPATH} \
                --host=aarch64-unknown-linux-gnu \
                --build=x86_64-linux-gnu \
                --with-build-python=yes \
                --without-ensurepip \
                ac_cv_buggy_getaddrinfo=no \
                ac_cv_file__dev_ptmx=yes \
                ac_cv_file__dev_ptc=no \
                --enable-optimizations
    make -j32 install
    make install

    # Create the necessary env and its link
    ${BUILD_PIP} install --upgrade pip crossenv
    ${BUILD_PYTHON} -m crossenv ${TARGET_PYTHON} ${CROSS_ENV}
    ${LN} -s  ${CROSS_ENV} ${CROSS_ENV_LN}
    ${CROSS_ENV_PIP} install wheel
    rm -rf ${BUILD_DIR}
done
