SHELL := /bin/bash

#
# Parameters
#

# Name of the container engine executable
OCI_EXE ?= docker

# Docker organization to pull the images from
DOCKCROSS_ORG ?= dockcross

# Exit if we don't have a DOCKCROSS_VERSION.
# If the shell has `export DOCKCROSS_VERSION=m.n.o` we'll get that.
ifndef DOCKCROSS_VERSION
	$(error DOCKCROSS_VERSION is not set)
endif

# Check we have a semantic version, abend. Make doesn't have regular expressions
# so delegate to the shell (defined above)
SEMVER := $(shell [[ $(DOCKCROSS_VERSION) =~ ^[0-9]+\.[0-9]+\.[0-9]+$$ ]] && echo matched)

ifdef SEMVER
	@echo Semantic version number given: $(DOCKCROSS_VERSION)
else
	$(error DOCKCROSS_VERSION is not semantic version number)
endif

# Tag images with semantic version number.
TAG = $(DOCKCROSS_VERSION)

# Directory where to generate the dockcross script for each images (e.g bin/dockcross-manylinux1-x64)
BIN = ./bin

# These images are built using the "build implicit rule"
STANDARD_IMAGES = linux-s390x android-arm android-arm64 linux-x86 linux-x64 linux-arm64 linux-armv5 linux-armv5-musl linux-armv6 linux-armv7 linux-armv7a linux-mips linux-mipsel linux-ppc64le windows-static-x86 windows-static-x64 windows-static-x64-posix windows-shared-x86 windows-shared-x64 windows-shared-x64-posix

# Generated Dockerfiles.
GEN_IMAGES = linux-s390x linux-mips manylinux1-x64 manylinux1-x86 manylinux2010-x64 manylinux2010-x86 manylinux2014-x64 web-wasm linux-arm64 windows-static-x86 windows-static-x64 windows-static-x64-posix windows-shared-x86 windows-shared-x64 windows-shared-x64-posix linux-armv7 linux-armv7a linux-armv5 linux-armv5-musl linux-ppc64le
GEN_IMAGE_DOCKERFILES = $(addsuffix /Dockerfile,$(GEN_IMAGES))

# These images are expected to have explicit rules for *both* build and testing
NON_STANDARD_IMAGES = web-wasm manylinux1-x64 manylinux1-x86 manylinux2010-x64 manylinux2010-x86 manylinux2014-x64

DOCKER_COMPOSITE_SOURCES = common.docker common.debian common.manylinux common.crosstool common.windows

# This list all available images
IMAGES = $(STANDARD_IMAGES) $(NON_STANDARD_IMAGES)

# Optional arguments for test runner (test/run.py) associated with "testing implicit rule"
linux-ppc64le.test_ARGS = --languages C
windows-static-x86.test_ARGS = --exe-suffix ".exe"
windows-static-x64.test_ARGS = --exe-suffix ".exe"
windows-static-x64-posix.test_ARGS = --exe-suffix ".exe"
windows-shared-x86.test_ARGS = --exe-suffix ".exe"
windows-shared-x64.test_ARGS = --exe-suffix ".exe"
windows-shared-x64-posix.test_ARGS = --exe-suffix ".exe"

# On CircleCI, do not attempt to delete container
# See https://circleci.com/docs/docker-btrfs-error/
RM = --rm
ifeq ("$(CIRCLECI)", "true")
	RM =
endif

#
# images: This target builds all IMAGES (because it is the first one, it is built by default)
#
images: base $(IMAGES)

#
# test: This target ensures all IMAGES are built and run the associated tests
#
test: base.test $(addsuffix .test,$(IMAGES))

#
# Generic Targets (can specialize later).
#

$(GEN_IMAGE_DOCKERFILES) Dockerfile: %Dockerfile: %Dockerfile.in $(DOCKER_COMPOSITE_SOURCES)
	sed \
		-e '/common.docker/ r common.docker' \
		-e '/common.debian/ r common.debian' \
		-e '/common.manylinux/ r common.manylinux' \
		-e '/common.crosstool/ r common.crosstool' \
		-e '/common.windows/ r common.windows' \
		$< > $@

#
# web-wasm
#
web-wasm: web-wasm/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	cp -r test web-wasm/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/web-wasm:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/web-wasm \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		web-wasm
	rm -rf web-wasm/test
	rm -rf $@/imagefiles

web-wasm.test: web-wasm
	cp -r test web-wasm/
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/web-wasm > $(BIN)/dockcross-web-wasm && chmod +x $(BIN)/dockcross-web-wasm
	$(BIN)/dockcross-web-wasm python test/run.py --exe-suffix ".js"
	rm -rf web-wasm/test

#
# manylinux2014-x64
#
manylinux2014-x64: manylinux2014-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/manylinux2014-x64:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/manylinux2014-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--file manylinux2014-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux2014-x64.test: manylinux2014-x64
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/manylinux2014-x64 > $(BIN)/dockcross-manylinux2014-x64 && chmod +x $(BIN)/dockcross-manylinux2014-x64
	$(BIN)/dockcross-manylinux2014-x64 /opt/python/cp35-cp35m/bin/python test/run.py

#
# manylinux2010-x64
#

manylinux2010-x64: manylinux2010-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/manylinux2010-x64:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/manylinux2010-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--file manylinux2010-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux2010-x64.test: manylinux2010-x64
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/manylinux2010-x64 > $(BIN)/dockcross-manylinux2010-x64 && chmod +x $(BIN)/dockcross-manylinux2010-x64
	$(BIN)/dockcross-manylinux2010-x64 /opt/python/cp35-cp35m/bin/python test/run.py

#
# manylinux2010-x86
#

manylinux2010-x86: manylinux2010-x86/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/manylinux2010-x86:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/manylinux2010-x86 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--file manylinux2010-x86/Dockerfile .
	rm -rf $@/imagefiles

manylinux2010-x86.test: manylinux2010-x86
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/manylinux2010-x86 > $(BIN)/dockcross-manylinux2010-x86 && chmod +x $(BIN)/dockcross-manylinux2010-x86
	$(BIN)/dockcross-manylinux2010-x86 /opt/python/cp35-cp35m/bin/python test/run.py

#
# manylinux1-x64
#

manylinux1-x64: manylinux1-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/manylinux1-x64:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/manylinux1-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--file manylinux1-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux1-x64.test: manylinux1-x64
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/manylinux1-x64 > $(BIN)/dockcross-manylinux1-x64 && chmod +x $(BIN)/dockcross-manylinux1-x64
	$(BIN)/dockcross-manylinux1-x64 /opt/python/cp35-cp35m/bin/python test/run.py

#
# manylinux1-x86
#

manylinux1-x86: manylinux1-x86/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/manylinux1-x86:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/manylinux1-x86 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--file manylinux1-x86/Dockerfile .
	rm -rf $@/imagefiles

manylinux1-x86.test: manylinux1-x86
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/manylinux1-x86 > $(BIN)/dockcross-manylinux1-x86 && chmod +x $(BIN)/dockcross-manylinux1-x86
	$(BIN)/dockcross-manylinux1-x86 /opt/python/cp35-cp35m/bin/python test/run.py

#
# base
#

base: Dockerfile imagefiles/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/dockcross-base:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/dockcross-base \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		.

base.test: base
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/dockcross-base > $(BIN)/dockcross-base && chmod +x $(BIN)/dockcross-base

#
# display
#
display_images:
	for image in $(IMAGES); do echo $$image; done

$(VERBOSE).SILENT: display_images

#
# build implicit rule
#

$(STANDARD_IMAGES): %: %/Dockerfile base
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(OCI_EXE) build --tag $(DOCKCROSS_ORG)/$@:$(TAG) \
		--build-arg IMAGE=$(DOCKCROSS_ORG)/$@ \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		$@
	rm -rf $@/imagefiles

#
# testing implicit rule
#
.SECONDEXPANSION:
$(addsuffix .test,$(STANDARD_IMAGES)): $$(basename $$@)
	$(OCI_EXE) run $(RM) $(DOCKCROSS_ORG)/$(basename $@) > $(BIN)/dockcross-$(basename $@) && chmod +x $(BIN)/dockcross-$(basename $@)
	$(BIN)/dockcross-$(basename $@) python test/run.py $($@_ARGS)

#
# testing prerequisites implicit rule
#
test.prerequisites:
	mkdir -p $(BIN)

$(addsuffix .test,base $(IMAGES)): test.prerequisites

.PHONY: base images $(IMAGES) test %.test
