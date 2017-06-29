dockcross
=========

Cross compiling toolchains in Docker images.

.. image:: https://circleci.com/gh/dockcross/dockcross/tree/master.svg?style=svg
  :target: https://circleci.com/gh/dockcross/dockcross/tree/master


Features
--------

* Pre-built and configured toolchains for cross compiling.
* Most images also contain an emulator for the target system.
* Commands in the container are run as the calling user, so that any created files have the expected ownership, (i.e. not root).
* Make variables (`CC`, `LD` etc) are set to point to the appropriate tools in the container.
* Recent `CMake <https://cmake.org>`_ and ninja are precompiled.
* `Conan.io <https://www.conan.io>`_ can be used as a package manager.
* Toolchain files configured for CMake.
* Current directory is mounted as the container's workdir, ``/work``.
* Works with the `Docker for Mac <https://docs.docker.com/docker-for-mac/>`_ and `Docker for Windows <https://docs.docker.com/docker-for-windows/>`_.


Cross compilers
---------------

.. |base-images| image:: https://images.microbadger.com/badges/image/dockcross/base.svg
  :target: https://microbadger.com/images/dockcross/base

dockcross/base
  |base-images| Base image for other toolchain images. From Debian Jessie with GCC,
  make, autotools, CMake, Ninja, Git, and Python.


.. |android-arm-images| image:: https://images.microbadger.com/badges/image/dockcross/android-arm.svg
  :target: https://microbadger.com/images/dockcross/android-arm

dockcross/android-arm
  |android-arm-images| The Android NDK standalone toolchain for the arm
  architecture.


.. |browser-asmjs-images| image:: https://images.microbadger.com/badges/image/dockcross/browser-asmjs.svg
  :target: https://microbadger.com/images/dockcross/browser-asmjs

dockcross/browser-asmjs
  |browser-asmjs-images| The Emscripten JavaScript cross compiler.


.. |linux-arm64-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-arm64.svg
  :target: https://microbadger.com/images/dockcross/linux-arm64

dockcross/linux-arm64
  |linux-arm64-images| Cross compiler for the 64-bit ARM platform on Linux,
  also known as AArch64.

dockcross/bare-armv7
  |bare-armv7| Cross compiler for the ARM-Cortex A7 platform on Bare-Metal!!

dockcross/bare-armv8
  |bare-armv8| Cross compiler for the ARM-Cortex A53 platform on Bare-Metal!!

.. |linux-armv5-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-armv5.svg
  :target: https://microbadger.com/images/dockcross/linux-armv5

dockcross/linux-armv5
  |linux-armv5-images| Linux armv5 cross compiler toolchain for legacy devices
  like the Parrot AR Drone.


.. |linux-armv6-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-armv6.svg
  :target: https://microbadger.com/images/dockcross/linux-armv6

dockcross/linux-armv6
  |linux-armv6-images| Linux ARMv6 cross compiler toolchain for the Raspberry
  Pi, etc.


.. |linux-armv7-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-armv7.svg
  :target: https://microbadger.com/images/dockcross/linux-armv7

dockcross/linux-armv7
  |linux-armv7-images| Generic Linux armv7 cross compiler toolchain.

.. |linux-mipsel-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-mipsel.svg
  :target: https://microbadger.com/images/dockcross/linux-mipsel

dockcross/linux-mipsel
  |linux-mipsel-images| Linux mipsel cross compiler toolchain for little endian MIPS GNU systems.

.. |linux-ppc64le-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-ppc64le.svg
  :target: https://microbadger.com/images/dockcross/linux-ppc64le

dockcross/linux-ppc64le
  |linux-ppc64le-images| Linux PowerPC 64 little endian cross compiler
  toolchain for the POWER8, etc.


.. |linux-x64-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-x64.svg
  :target: https://microbadger.com/images/dockcross/linux-x64

dockcross/linux-x64
  |linux-x64-images| Linux x86_64 / amd64 compiler. Since the Docker image is
  natively x86_64, this is not actually a cross compiler.


.. |linux-x86-images| image:: https://images.microbadger.com/badges/image/dockcross/linux-x86.svg
  :target: https://microbadger.com/images/dockcross/linux-x86

dockcross/linux-x86
  |linux-x86-images| Linux i686 cross compiler.


.. |manylinux-x64-images| image:: https://images.microbadger.com/badges/image/dockcross/manylinux-x64.svg
  :target: https://microbadger.com/images/dockcross/manylinux-x64

dockcross/manylinux-x64
  |manylinux-x64-images| Docker `manylinux <https://github.com/pypa/manylinux>`_ image for building Linux x86_64 / amd64 `Python wheel packages <http://pythonwheels.com/>`_.
  Also has support for the dockcross script, and it has installations of CMake, Ninja, and `scikit-build <http://scikit-build.org>`_


.. |manylinux-x86-images| image:: https://images.microbadger.com/badges/image/dockcross/manylinux-x86.svg
  :target: https://microbadger.com/images/dockcross/manylinux-x86

dockcross/manylinux-x86
  |manylinux-x86-images| Docker `manylinux <https://github.com/pypa/manylinux>`_ image for building Linux i686 `Python wheel packages <http://pythonwheels.com/>`_.
  Also has support for the dockcross script, and it has installations of CMake, Ninja, and `scikit-build <http://scikit-build.org>`_


.. |windows-x64-images| image:: https://images.microbadger.com/badges/image/dockcross/windows-x64.svg
  :target: https://microbadger.com/images/dockcross/windows-x64

dockcross/windows-x64
  |windows-x64-images| 64-bit Windows cross-compiler based on MXE/MinGW-w64.


.. |windows-x86-images| image:: https://images.microbadger.com/badges/image/dockcross/windows-x86.svg
  :target: https://microbadger.com/images/dockcross/windows-x86

dockcross/windows-x86
  |windows-x86-images| 32-bit Windows cross-compiler based on MXE/MinGW-w64.


Installation
------------

This image does not need to be run manually. Instead, there is a helper script
to execute build commands on source code existing on the local host filesystem. This
script is bundled with the image.

To install the helper script, run one of the images with no arguments, and
redirect the output to a file::

  docker run --rm CROSS_COMPILER_IMAGE_NAME > ./dockcross
  chmod +x ./dockcross
  mv ./dockcross ~/bin/

Where `CROSS_COMPILER_IMAGE_NAME` is the name of the cross-compiler toolchain
Docker instance, e.g. `dockcross/linux-armv7`.


Usage
-----

For the impatient, here's how to compile a hello world for armv7::

  cd ~/src/dockcross
  docker run --rm dockcross/linux-armv7 > ./dockcross-linux-armv7
  chmod +x ./dockcross-linux-armv7
  ./dockcross-linux-armv7 bash -c '$CC test/C/hello.c -o hello_arm'

Note how invoking any toolchain command (make, gcc, etc.) is just a matter of prepending the **dockcross** script on the commandline::

  ./dockcross-linux-armv7 [command] [args...]

The dockcross script will execute the given command-line inside the container,
along with all arguments passed after the command. Commands that evaluate
environmental variables in the image, like `$CC` above, should be executed in
`bash -c`. The present working directory is mounted within the image, which
can be used to make source code available in the Docker container.


Built-in update commands
------------------------

A special update command can be executed that will update the
source cross-compiler Docker image or the dockcross script itself.

- ``dockcross [--] command [args...]``: Forces a command to run inside the container (in case of a name clash with a built-in command), use ``--`` before the command.
- ``dockcross update-image``: Fetch the latest version of the docker image.
- ``dockcross update-script``: Update the installed dockcross script with the one bundled in the image.
- ``dockcross update``: Update both the docker image, and the dockcross script.


Download all images
-------------------

To easily download all images, the convenience target ``display_images`` could be used::

  curl https://raw.githubusercontent.com/dockcross/dockcross/master/Makefile -o dockcross-Makefile
  for image in $(make -f dockcross-Makefile display_images); do
    echo "Pulling dockcross/$image"
    docker pull dockcross/$image
  done

Install all dockcross scripts
-----------------------------

To automatically install in ``~/bin`` the dockcross scripts for each images already downloaded, the
convenience target ``display_images`` could be used::

  curl https://raw.githubusercontent.com/dockcross/dockcross/master/Makefile -o dockcross-Makefile
  for image in $(make -f dockcross-Makefile display_images); do
    if [[ $(docker images -q dockcross/$image) == "" ]]; then
      echo "~/bin/dockcross-$image skipping: image not found locally"
      continue
    fi
    echo "~/bin/dockcross-$image ok"
    docker run dockcross/$image > ~/bin/dockcross-$image && \
    chmod u+x  ~/bin/dockcross-$image
  done


Dockcross configuration
-----------------------

The following environmental variables and command-line options are used. In
all cases, the command-line option overrides the environment variable.

DOCKCROSS_CONFIG / --config|-c <path-to-config-file>
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This file is sourced, if it exists, before executing the rest of the dockcross
script.

Default: ``~/.dockcross``

DOCKCROSS_IMAGE / --image|-i <docker-image-name>
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Docker cross-compiler image to run.

Default: Image with which the script was created.

DOCKCROSS_ARGS / --args|-a <docker-run-args>
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Extra arguments to pass to the ``docker run`` command. Quote the entire set of
args if they contain spaces.


Per-project dockcross configuration
-----------------------------------

If a shell script named ``.dockcross`` is found in the current directory where
the dockcross script is started, it is executed before the dockcross script
``command`` argument.  The shell script is expected to have a shebang like
``#!/bin/bash``.

For example, commands like ``git config --global advice.detachedHead false`` can
be added to this script.


Examples
--------

1. ``dockcross make``: Build the *Makefile* in the current directory.
2. ``dockcross cmake -Bbuild -H. -GNinja``: Run CMake with a build directory
   ``./build`` for a *CMakeLists.txt* file in the current directory and generate
   ``ninja`` build configuration files.
3. ``dockcross ninja -Cbuild``: Run ninja in the ``./build`` directory.
4. ``dockcross bash -c '$CC test/C/hello.c -o hello'``: Build the *hello.c* file
   with the compiler identified with the ``CC`` environmental variable in the
   build environment.
5. ``dockcross bash``: Run an interactive shell in the build environment.

Note that commands are executed verbatim. If any shell processing for
environment variable expansion or redirection is required, please use
`bash -c 'command args...'`.


Articles
--------

- `dockcross: C++ Write Once, Run Anywhere
  <https://nbviewer.jupyter.org/format/slides/github/dockcross/cxx-write-once-run-anywhere/blob/master/dockcross_CXX_Write_Once_Run_Anywhere.ipynb#/>`_
- `Cross-compiling binaries for multiple architectures with Docker
  <http://blogs.nopcode.org/brainstorm/2016/07/26/cross-compiling-with-docker>`_


---

Credits go to `sdt/docker-raspberry-pi-cross-compiler <https://github.com/sdt/docker-raspberry-pi-cross-compiler>`_, who invented the base of the **dockcross** script.
