cross-compilers
===============

Dockerfiles for cross compiling in a Docker container.

## Features

* different toolchains for cross compiling
* commands in the container are run as the calling user, so that any created files have the expected ownership (ie. not root)
* make variables (`CC`, `LD` etc) are set to point to the appropriate tools in the container
* cmake and ninja are precompiled available with a toolchain file for cmake
* current directory is mounted as the container's workdir, `/build`
* works with boot2docker on OSX

## Installation

This image is not intended to be run manually. Instead, there is a helper script which comes bundled with the image.

To install the helper script, run the image with no arguments, and redirect the output to a file.

eg.
```
docker run CROSS_COMPILER_IMAGE_NAME > dockcross
chmod +x dockcross
mv dockcross ~/bin/
```

## Usage

`dockcross [command] [args...]`

Execute the given command-line inside the container.

If the command matches one of the dockcross built-in commands (see below), that will be executed locally, otherwise the command is executed inside the container.

---

`dockcross -- [command] [args...]`

To force a command to run inside the container (in case of a name clash with a built-in command), use `--` before the command.

### Built-in commands

`dockcross update-image`

Fetch the latest version of the docker image.

---

`dockcross update-script`

Update the installed dockcross script with the one bundled in the image.

----

`dockcross update`

Update both the docker image, and the dockcross script.

## Configuration

The following command-line options and environment variables are used. In all cases, the command-line option overrides the environment variable.

### DOCKCROSS_CONFIG / --config &lt;path-to-config-file&gt;

This file is sourced if it exists.

Default: `~/.dockcross`

### DOCKCROSS_IMAGE / --image &lt;docker-image-name&gt;

The docker image to run.

Default: sdt4docker/raspberry-pi-cross-compiler

### DOCKCROSS_ARGS / --args &lt;docker-run-args&gt;

Extra arguments to pass to the `docker run` command.

## Examples

`dockcross make`

Build the Makefile in the current directory.

---

`dockcross cmake -Bbuild -H. -GNinja`

Run CMake with a build directory "build" for the CMakeLists.txt in the current directory and generate `ninja` files.

`dockcross ninja -Cbuild`

Run ninja in the generated build directory.

---

`dockcross bash -c 'find . -name \*.o | sort > objects.txt'`

Note that commands are executed verbatim. If you require any shell processing for environment variable expansion or redirection, please use `bash -c 'command args...'`.

---

Credits go to sdt [sdt/docker-raspberry-pi-cross-compiler](https://github.com/sdt/docker-raspberry-pi-cross-compiler) on [GitHub](https://github.com), who invented the base of the `dockcross` script.
