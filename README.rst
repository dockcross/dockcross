dockcross
=========

Cross compiling toolchains in Docker images.

.. image:: https://circleci.com/gh/dockcross/dockcross/tree/master.svg?style=svg
  :target: https://circleci.com/gh/dockcross/dockcross/tree/master


Features
--------

* Different toolchains for cross compiling.
* Most images also contain an emulator for the target system.
* Commands in the container are run as the calling user, so that any created files have the expected ownership, (i.e. not root).
* Make variables (`CC`, `LD` etc) are set to point to the appropriate tools in the container.
* Recent `CMake <https://cmake.org>`_ and ninja are precompiled. Toolchain files configured for CMake.
* Current directory is mounted as the container's workdir, ``/work``.
* Works with the `Docker Toolbox <https://www.docker.com/products/docker-toolbox>`_ on Mac OSX.


Cross compilers
---------------

.. |base-images| image:: https://badge.imagelayers.io/dockcross/base:latest.svg
  :target: https://imagelayers.io/?images=dockcross/base:latest

dockcross/base
  |base-images| Base image for other toolchain images. From Debian Jessie with GCC,
  make, autotools, CMake, Ninja, Git, and Python.


.. |android-arm-images| image:: https://badge.imagelayers.io/dockcross/android-arm:latest.svg
  :target: https://imagelayers.io/?images=dockcross/android-arm:latest

dockcross/android-arm
  |android-arm-images| The Android NDK standalone toolchain for the arm
  architecture.


.. |browser-asmjs-images| image:: https://badge.imagelayers.io/dockcross/browser-asmjs:latest.svg
  :target: https://imagelayers.io/?images=dockcross/browser-asmjs:latest

dockcross/browser-asmjs
  |browser-asmjs-images| The Emscripten JavaScript cross compiler.


.. |linux-arm64-images| image:: https://badge.imagelayers.io/dockcross/linux-arm64:latest.svg
  :target: https://imagelayers.io/?images=dockcross/linux-arm64:latest

dockcross/linux-arm64
  |linux-arm64-images| Cross compiler for the 64-bit ARM platform on Linux,
  also known as AArch64.


.. |linux-armv5-images| image:: https://badge.imagelayers.io/dockcross/linux-armv5:latest.svg
  :target: https://imagelayers.io/?images=dockcross/linux-armv5:latest

dockcross/linux-armv5
  |linux-armv5-images| Linux armv5 cross compiler toolchain for legacy devices
  like the Parrot AR Drone.


.. |linux-armv6-images| image:: https://badge.imagelayers.io/dockcross/linux-armv6:latest.svg
  :target: https://imagelayers.io/?images=dockcross/linux-armv6:latest

dockcross/linux-armv6
  |linux-armv6-images| Linux ARMv6 cross compiler toolchain for the Raspberry
  Pi, etc.


.. |linux-armv7-images| image:: https://badge.imagelayers.io/dockcross/linux-armv7:latest.svg
  :target: https://imagelayers.io/?images=dockcross/linux-armv7:latest

dockcross/linux-armv7
  |linux-armv7-images| Generic Linux armv7 cross compiler toolchain.


.. |linux-ppc64le-images| image:: https://badge.imagelayers.io/dockcross/linux-ppc64le:latest.svg
  :target: https://imagelayers.io/?images=dockcross/linux-ppc64le:latest

dockcross/linux-ppc64le
  |linux-ppc64le-images| Linux PowerPC 64 little endian cross compiler
  toolchain for the POWER8, etc.


.. |linux-x64-images| image:: https://badge.imagelayers.io/dockcross/linux-x64:latest.svg
  :target: https://imagelayers.io/?images=dockcross/linux-x64:latest

dockcross/linux-x64
  |linux-x64-images| Linux x86_64 / amd64 compiler. Since the Docker image is
  natively x86_64, this is not actually a cross compiler.


.. |linux-x86-images| image:: https://badge.imagelayers.io/dockcross/linux-x86:latest.svg
  :target: https://imagelayers.io/?images=dockcross/linux-x86:latest

dockcross/linux-x86
  |linux-x86-images| Linux i686 cross compiler.


.. |windows-x64-images| image:: https://badge.imagelayers.io/dockcross/windows-x64:latest.svg
  :target: https://imagelayers.io/?images=dockcross/windows-x64:latest

dockcross/windows-x64
  |windows-x64-images| 64-bit Windows cross-compiler based on MXE/MinGW-w64.


.. |windows-x86-images| image:: https://badge.imagelayers.io/dockcross/windows-x86:latest.svg
  :target: https://imagelayers.io/?images=dockcross/windows-x86:latest

dockcross/windows-x86
  |windows-x86-images| 32-bit Windows cross-compiler based on MXE/MinGW-w64.


Installation
------------

This image does not need to be run manually. Instead, there is a helper script
to execute build commands on source code existing on the local host filesystem. This
script is bundled with the image.

To install the helper script, run one of the images with no arguments, and
redirect the output to a file::

  docker run --rm CROSS_COMPILER_IMAGE_NAME > ~/bin/dockcross && chmod +x ~/bin/dockcross

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
environmental variable in the image, like `$CC` above, should be executed in
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


Configuration
-------------

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

Extra arguments to pass to the ``docker run`` command.


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

---

Credits go to `sdt/docker-raspberry-pi-cross-compiler <https://github.com/sdt/docker-raspberry-pi-cross-compiler>`_, who invented the base of the **dockcross** script.
