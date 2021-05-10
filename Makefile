
#
# Parameters
#

# Name of the docker executable
DOCKER = docker

# Docker organization to pull the images from
ORG = dockcross

# Directory where to generate the dockcross script for each images (e.g bin/dockcross-manylinux1-x64)
BIN = ./bin

# These images are built using the "build implicit rule"
STANDARD_IMAGES = linux-s390x android-arm android-arm64 android-x86 android-x86_64 linux-x86 linux-x64 linux-armv8 linux-armv8-musl linux-armv8-rpi4 linux-armv5 linux-m68k linux-armv5-musl linux-armv6 linux-armv6-musl linux-armv6-rpi linux-armv7 linux-armv7a linux-armv7l-musl linux-mips linux-mips64 linux-mipsel linux-ppc32 linux-ppc64 windows-static-x86 windows-static-x64 windows-static-x64-posix windows-shared-x86 windows-shared-x64 windows-shared-x64-posix

# Generated Dockerfiles.
GEN_IMAGES = linux-s390x android-arm android-arm64 linux-x86 linux-x64 linux-mips linux-mips64 linux-mipsel manylinux1-x64 manylinux1-x86 manylinux2010-x64 manylinux2010-x86 manylinux2014-x64 manylinux2014-x86 manylinux2014-aarch64 linux-m68k web-wasm linux-armv8 linux-armv8-musl linux-armv8-rpi4 linux-ppc32 linux-ppc64 windows-static-x86 windows-static-x64 windows-static-x64-posix windows-shared-x86 windows-shared-x64 windows-shared-x64-posix linux-armv7 linux-armv7a linux-armv7l-musl linux-armv6 linux-armv6-musl linux-armv6-rpi linux-armv5 linux-armv5-musl
GEN_IMAGE_DOCKERFILES = $(addsuffix /Dockerfile,$(GEN_IMAGES))

# These images are expected to have explicit rules for *both* build and testing
NON_STANDARD_IMAGES = web-wasm manylinux1-x64 manylinux1-x86 manylinux2010-x64 manylinux2010-x86 manylinux2014-x64 manylinux2014-x86 manylinux2014-aarch64

DOCKER_COMPOSITE_SOURCES = common.docker common.debian common.manylinux common.crosstool common.windows common-manylinux.crosstool common.dockcross common.lib common.label-and-env

# This list all available images
IMAGES = $(STANDARD_IMAGES) $(NON_STANDARD_IMAGES)

# Optional arguments for test runner (test/run.py) associated with "testing implicit rule"
linux-ppc64.test_ARGS = --languages C
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

# Tag images with date and Git short hash in addition to revision
TAG := $(shell date '+%Y%m%d')-$(shell git rev-parse --short HEAD)

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
		-e '/common-manylinux.crosstool/ r common-manylinux.crosstool' \
		-e '/common.windows/ r common.windows' \
		-e '/common.dockcross/ r common.dockcross' \
		-e '/common.lib/ r common.lib' \
		-e '/common.label-and-env/ r common.label-and-env' \
		$< > $@

#
# web-wasm
#
web-wasm: web-wasm/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	cp -r test web-wasm/
	$(DOCKER) build -t $(ORG)/web-wasm:latest \
		--build-arg IMAGE=$(ORG)/web-wasm \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		web-wasm
	$(DOCKER) build -t $(ORG)/web-wasm:$(TAG) \
		--build-arg IMAGE=$(ORG)/web-wasm \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		web-wasm
	rm -rf web-wasm/test
	rm -rf $@/imagefiles

web-wasm.test: web-wasm
	cp -r test web-wasm/
	$(DOCKER) run $(RM) dockcross/web-wasm > $(BIN)/dockcross-web-wasm && chmod +x $(BIN)/dockcross-web-wasm
	$(BIN)/dockcross-web-wasm python test/run.py --exe-suffix ".js"
	rm -rf web-wasm/test

#
# manylinux2014-aarch64
#
manylinux2014-aarch64: manylinux2014-aarch64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux2014-aarch64:latest \
		--build-arg IMAGE=$(ORG)/manylinux2014-aarch64 \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-aarch64/Dockerfile .
	$(DOCKER) build -t $(ORG)/manylinux2014-aarch64:$(TAG) \
		--build-arg IMAGE=$(ORG)/manylinux2014-aarch64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-aarch64/Dockerfile .
	rm -rf $@/imagefiles

manylinux2014-aarch64.test: manylinux2014-aarch64
	$(DOCKER) run $(RM) dockcross/manylinux2014-aarch64 > $(BIN)/dockcross-manylinux2014-aarch64 && chmod +x $(BIN)/dockcross-manylinux2014-aarch64
	$(BIN)/dockcross-manylinux2014-aarch64 /opt/python/cp38-cp38/bin/python test/run.py

#
# manylinux2014-x64
#
manylinux2014-x64: manylinux2014-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux2014-x64:latest \
		--build-arg IMAGE=$(ORG)/manylinux2014-x64 \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-x64/Dockerfile .
	$(DOCKER) build -t $(ORG)/manylinux2014-x64:$(TAG) \
		--build-arg IMAGE=$(ORG)/manylinux2014-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux2014-x64.test: manylinux2014-x64
	$(DOCKER) run $(RM) dockcross/manylinux2014-x64 > $(BIN)/dockcross-manylinux2014-x64 && chmod +x $(BIN)/dockcross-manylinux2014-x64
	$(BIN)/dockcross-manylinux2014-x64 /opt/python/cp38-cp38/bin/python test/run.py

#
# manylinux2014-x86
#
manylinux2014-x86: manylinux2014-x86/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux2014-x86:latest \
		--build-arg IMAGE=$(ORG)/manylinux2014-x86 \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-x86/Dockerfile .
	$(DOCKER) build -t $(ORG)/manylinux2014-x86:$(TAG) \
		--build-arg IMAGE=$(ORG)/manylinux2014-x86 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-x86/Dockerfile .
	rm -rf $@/imagefiles

manylinux2014-x86.test: manylinux2014-x86
	$(DOCKER) run $(RM) dockcross/manylinux2014-x86 > $(BIN)/dockcross-manylinux2014-x86 && chmod +x $(BIN)/dockcross-manylinux2014-x86
	$(BIN)/dockcross-manylinux2014-x86 /opt/python/cp38-cp38/bin/python test/run.py

#
# manylinux2010-x64
#

manylinux2010-x64: manylinux2010-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux2010-x64:latest \
		--build-arg IMAGE=$(ORG)/manylinux2010-x64 \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2010-x64/Dockerfile .
	$(DOCKER) build -t $(ORG)/manylinux2010-x64:$(TAG) \
		--build-arg IMAGE=$(ORG)/manylinux2010-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2010-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux2010-x64.test: manylinux2010-x64
	$(DOCKER) run $(RM) dockcross/manylinux2010-x64 > $(BIN)/dockcross-manylinux2010-x64 && chmod +x $(BIN)/dockcross-manylinux2010-x64
	$(BIN)/dockcross-manylinux2010-x64 /opt/python/cp38-cp38/bin/python test/run.py

#
# manylinux2010-x86
#

manylinux2010-x86: manylinux2010-x86/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux2010-x86:latest \
		--build-arg IMAGE=$(ORG)/manylinux2010-x86 \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2010-x86/Dockerfile .
	$(DOCKER) build -t $(ORG)/manylinux2010-x86:$(TAG) \
		--build-arg IMAGE=$(ORG)/manylinux2010-x86 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2010-x86/Dockerfile .
	rm -rf $@/imagefiles

manylinux2010-x86.test: manylinux2010-x86
	$(DOCKER) run $(RM) dockcross/manylinux2010-x86 > $(BIN)/dockcross-manylinux2010-x86 && chmod +x $(BIN)/dockcross-manylinux2010-x86
	$(BIN)/dockcross-manylinux2010-x86 /opt/python/cp38-cp38/bin/python test/run.py

#
# manylinux1-x64
#

manylinux1-x64: manylinux1-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux1-x64:latest \
		--build-arg IMAGE=$(ORG)/manylinux1-x64 \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux1-x64/Dockerfile .
	$(DOCKER) build -t $(ORG)/manylinux1-x64:$(TAG) \
		--build-arg IMAGE=$(ORG)/manylinux1-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux1-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux1-x64.test: manylinux1-x64
	$(DOCKER) run $(RM) dockcross/manylinux1-x64 > $(BIN)/dockcross-manylinux1-x64 && chmod +x $(BIN)/dockcross-manylinux1-x64
	$(BIN)/dockcross-manylinux1-x64 /opt/python/cp38-cp38/bin/python test/run.py

#
# manylinux1-x86
#

manylinux1-x86: manylinux1-x86/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux1-x86:latest \
		--build-arg IMAGE=$(ORG)/manylinux1-x86 \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux1-x86/Dockerfile .
	$(DOCKER) build -t $(ORG)/manylinux1-x86:$(TAG) \
		--build-arg IMAGE=$(ORG)/manylinux1-x86 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux1-x86/Dockerfile .
	rm -rf $@/imagefiles

manylinux1-x86.test: manylinux1-x86
	$(DOCKER) run $(RM) dockcross/manylinux1-x86 > $(BIN)/dockcross-manylinux1-x86 && chmod +x $(BIN)/dockcross-manylinux1-x86
	$(BIN)/dockcross-manylinux1-x86 /opt/python/cp38-cp38/bin/python test/run.py

#
# base
#

base: Dockerfile imagefiles/
	$(DOCKER) build -t $(ORG)/base:latest \
		--build-arg IMAGE=$(ORG)/base \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		.
	$(DOCKER) build -t $(ORG)/base:$(TAG) \
		--build-arg IMAGE=$(ORG)/base \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		.

base.test: base
	$(DOCKER) run $(RM) dockcross/base > $(BIN)/dockcross-base && chmod +x $(BIN)/dockcross-base

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
	$(DOCKER) build -t $(ORG)/$@:latest \
		--build-arg IMAGE=$(ORG)/$@ \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		$@
	$(DOCKER) build -t $(ORG)/$@:$(TAG) \
		--build-arg IMAGE=$(ORG)/$@ \
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
	$(DOCKER) run $(RM) dockcross/$(basename $@) > $(BIN)/dockcross-$(basename $@) && chmod +x $(BIN)/dockcross-$(basename $@)
	$(BIN)/dockcross-$(basename $@) python3 test/run.py $($@_ARGS)

#
# testing prerequisites implicit rule
#
test.prerequisites:
	mkdir -p $(BIN)

$(addsuffix .test,base $(IMAGES)): test.prerequisites

.PHONY: base images $(IMAGES) test %.test
