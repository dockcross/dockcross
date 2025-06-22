
#
# Parameters
#

# Name of the docker-equivalent executable for building images.
# OCI: open container interface.
# Common values: docker, podman, buildah
DOCKER := $(or $(OCI_EXE), docker)
BUILD_DOCKER := $(or $(BUILD_DOCKER), $(DOCKER))
BUILDAH := $(or $(BUILDAH_EXE), buildah)
# Name of the docker-equivalent executable for running test containers.
# Supports the use case:
#
#   DOCKER=buildah
#   TEST_DOCKER=podman
#
# because buildah does not run containers.
TEST_DOCKER := $(or $(TEST_DOCKER), $(DOCKER))

# The build sub-command. Use:
#
#   export "BUILD_CMD=buildx build --platform linux/amd64,linux/arm64"
#
# to generate multi-platform images.
BUILD_CMD := $(or $(BUILD_CMD), build)
TAG_FLAG := $(or $(TAG_FLAG), --tag)

# Docker organization to pull the images from
ORG = dockcross

# Host architecture
HOST_ARCH := $(or $(HOST_ARCH), $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/'))

# Directory where to generate the dockcross script for each images (e.g bin/dockcross-manylinux2014-x64)
BIN = ./bin

RM = --rm

# These images are built using the "build implicit rule"
STANDARD_IMAGES := android-arm android-arm64 android-x86 android-x86_64 \
	linux-i686 linux-x86 linux-x64 linux-x64-clang linux-arm64-musl linux-arm64-full \
	linux-armv5 linux-armv5-musl linux-armv5-uclibc linux-m68k-uclibc linux-s390x linux-x64-tinycc \
	linux-armv6 linux-armv6-lts linux-armv6-musl linux-arm64-lts linux-mipsel-lts \
	linux-armv7l-musl linux-armv7 linux-armv7a linux-armv7-lts linux-armv7a-lts linux-x86_64-full \
	linux-mips linux-mips-uclibc linux-mips-lts linux-ppc linux-ppc64le linux-ppc64le-lts linux-riscv64 linux-riscv32 linux-xtensa-uclibc \
	windows-static-x86 windows-static-x64 windows-static-x64-posix windows-armv7 \
	windows-shared-x86 windows-shared-x64 windows-shared-x64-posix windows-arm64 \
	bare-armv7emhf-nano_newlib

# Generated Dockerfiles.
GEN_IMAGES := android-arm android-arm64 \
	linux-i686 linux-x86 linux-x64 linux-x64-clang linux-arm64 linux-arm64-musl linux-arm64-full \
	manylinux_2_28-x64 manylinux_2_34-x64 \
	manylinux2014-x64 manylinux2014-x86 \
	manylinux2014-aarch64 linux-arm64-lts \
	web-wasm web-wasi web-wasi-emulated-threads web-wasi-threads linux-mips linux-mips-uclibc linux-mips-lts windows-arm64 windows-armv7 \
	windows-static-x86 windows-static-x64 windows-static-x64-posix \
	windows-shared-x86 windows-shared-x64 windows-shared-x64-posix \
	linux-armv7 linux-armv7a linux-armv7l-musl linux-armv7-lts linux-armv7a-lts linux-x86_64-full \
	linux-armv6 linux-armv6-lts linux-armv6-musl linux-mipsel-lts \
	linux-armv5 linux-armv5-musl linux-armv5-uclibc linux-ppc linux-ppc64le linux-ppc64le-lts linux-s390x \
	linux-riscv64 linux-riscv32 linux-m68k-uclibc linux-x64-tinycc linux-xtensa-uclibc \
	bare-armv7emhf-nano_newlib

# Generate both amd64 and arm64 images
MULTIARCH_IMAGES :=  linux-arm64 \
	web-wasi web-wasi-emulated-threads

GEN_IMAGE_DOCKERFILES = $(addsuffix /Dockerfile,$(GEN_IMAGES))

# These images are expected to have explicit rules for *both* build and testing
NON_STANDARD_IMAGES := manylinux_2_28-x64 manylinux_2_34-x64 manylinux2014-x64 manylinux2014-x86 \
		      manylinux2014-aarch64 web-wasm web-wasi-emulated-threads web-wasi-threads

# Docker composite files
DOCKER_COMPOSITE_SOURCES = common.docker common.debian common.manylinux2014 common.manylinux_2_28 common.manylinux_2_34 common.buildroot \
	common.crosstool common.webassembly common.windows common-manylinux.crosstool common.dockcross \
	common.label-and-env
DOCKER_COMPOSITE_FOLDER_PATH = common/
DOCKER_COMPOSITE_PATH = $(addprefix $(DOCKER_COMPOSITE_FOLDER_PATH),$(DOCKER_COMPOSITE_SOURCES))

# This list all available images
IMAGES := $(STANDARD_IMAGES) $(NON_STANDARD_IMAGES) $(MULTIARCH_IMAGES)

# Optional arguments for test runner (test/run.py) associated with "testing implicit rule"
linux-x64-tinycc.test_ARGS = --languages C
windows-static-x86.test_ARGS = --exe-suffix ".exe"
windows-static-x64.test_ARGS = --exe-suffix ".exe"
windows-static-x64-posix.test_ARGS = --exe-suffix ".exe"
windows-shared-x86.test_ARGS = --exe-suffix ".exe"
windows-shared-x64.test_ARGS = --exe-suffix ".exe"
windows-shared-x64-posix.test_ARGS = --exe-suffix ".exe"
windows-armv7.test_ARGS = --exe-suffix ".exe"
windows-arm64.test_ARGS = --exe-suffix ".exe"
bare-armv7emhf-nano_newlib.test_ARGS = --linker-flags="--specs=nosys.specs"

# Tag images with date and Git short hash in addition to revision
TAG := $(shell date '+%Y%m%d')-$(shell git rev-parse --short HEAD)

# shellcheck executable
SHELLCHECK := shellcheck

# Defines the level of verification (error, warning, info...)
SHELLCHECK_SEVERITY_LEVEL := error

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

$(GEN_IMAGE_DOCKERFILES) Dockerfile: %Dockerfile: %Dockerfile.in $(DOCKER_COMPOSITE_PATH)
	sed $(foreach f,$(DOCKER_COMPOSITE_SOURCES),-e '/$(f)/ r $(DOCKER_COMPOSITE_FOLDER_PATH)$(f)') $< > $@

#
# web-wasm
#
ifeq ($(HOST_ARCH),amd64)
  EMSCRIPTEN_HOST_ARCH_TAG = ""
endif
ifeq ($(HOST_ARCH),arm64)
  EMSCRIPTEN_HOST_ARCH_TAG = "-arm64"
endif
web-wasm: web-wasm/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	cp -r test web-wasm/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/web-wasm:$(TAG)-$(HOST_ARCH) \
		$(TAG_FLAG) $(ORG)/web-wasm:latest-$(HOST_ARCH) \
		--build-arg IMAGE=$(ORG)/web-wasm \
		--build-arg VERSION=$(TAG) \
		--build-arg HOST_ARCH_TAG=$(EMSCRIPTEN_HOST_ARCH_TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		web-wasm
	rm -rf web-wasm/test
	rm -rf $@/imagefiles

web-wasm.test: web-wasm
	cp -r test web-wasm/
	$(TEST_DOCKER) run $(RM) $(ORG)/web-wasm:latest-$(HOST_ARCH) > $(BIN)/dockcross-web-wasm && chmod +x $(BIN)/dockcross-web-wasm
	$(BIN)/dockcross-web-wasm -i $(ORG)/web-wasm:latest-$(HOST_ARCH) python test/run.py --exe-suffix ".js"
	rm -rf web-wasm/test

#
# web-wasi-threads
#
web-wasi-threads: web-wasi web-wasi-threads/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	cp -r test web-wasi-threads/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/web-wasi-threads:$(TAG)-$(HOST_ARCH) \
		-t $(ORG)/web-wasi-threads:latest-$(HOST_ARCH) \
		--build-arg IMAGE=$(ORG)/web-wasi-threads \
		--build-arg VERSION=$(TAG) \
		--build-arg HOST_ARCH=$(HOST_ARCH) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		web-wasi-threads

#
# manylinux2014-aarch64
#
manylinux2014-aarch64: manylinux2014-aarch64/Dockerfile manylinux2014-x64
	@# Register qemu
	docker run --rm --privileged hypriot/qemu-register
	@# Get libstdc++ from quay.io/pypa/manylinux2014_aarch64 container
	docker run -v `pwd`:/host --rm -e LIB_PATH=/host/$@/xc_script/ quay.io/pypa/manylinux2014_aarch64 bash -c "PASS=1 /host/$@/xc_script/docker_setup_scrpits/copy_libstd.sh"
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/manylinux2014-aarch64:$(TAG) \
		$(TAG_FLAG) $(ORG)/manylinux2014-aarch64:latest \
		--build-arg IMAGE=$(ORG)/manylinux2014-aarch64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-aarch64/Dockerfile .
	rm -rf $@/imagefiles
	@# libstdc++ is coppied into image, now remove it
	docker run -v `pwd`:/host --rm quay.io/pypa/manylinux2014_aarch64 bash -c "rm -rf /host/$@/xc_script/usr"

manylinux2014-aarch64.test: manylinux2014-aarch64
	$(TEST_DOCKER) run $(RM) $(ORG)/manylinux2014-aarch64:latest > $(BIN)/dockcross-manylinux2014-aarch64 \
		&& chmod +x $(BIN)/dockcross-manylinux2014-aarch64
	$(BIN)/dockcross-manylinux2014-aarch64 -i $(ORG)/manylinux2014-aarch64:latest /opt/python/cp311-cp311/bin/python test/run.py

#
# manylinux_2_28-x64
#
manylinux_2_28-x64: manylinux_2_28-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/manylinux_2_28-x64:$(TAG) \
		$(TAG_FLAG) $(ORG)/manylinux_2_28-x64:latest \
		--build-arg IMAGE=$(ORG)/manylinux_2_28-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux_2_28-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux_2_28-x64.test: manylinux_2_28-x64
	$(TEST_DOCKER) run $(RM) $(ORG)/manylinux_2_28-x64:latest > $(BIN)/dockcross-manylinux_2_28-x64 \
		&& chmod +x $(BIN)/dockcross-manylinux_2_28-x64
	$(BIN)/dockcross-manylinux_2_28-x64 -i $(ORG)/manylinux_2_28-x64:latest /opt/python/cp310-cp310/bin/python test/run.py

#
# manylinux_2_34-x64
#
manylinux_2_34-x64: manylinux_2_34-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(DOCKER) build -t $(ORG)/manylinux_2_34-x64:$(TAG) \
		-t $(ORG)/manylinux_2_34-x64:latest \
		--build-arg IMAGE=$(ORG)/manylinux_2_34-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux_2_34-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux_2_34-x64.test: manylinux_2_34-x64
	$(DOCKER) run $(RM) $(ORG)/manylinux_2_34-x64:latest > $(BIN)/dockcross-manylinux_2_34-x64 \
		&& chmod +x $(BIN)/dockcross-manylinux_2_34-x64
	$(BIN)/dockcross-manylinux_2_34-x64 -i $(ORG)/manylinux_2_34-x64:latest /opt/python/cp310-cp310/bin/python test/run.py

#
# manylinux2014-x64
#
manylinux2014-x64: manylinux2014-x64/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/manylinux2014-x64:$(TAG) \
		$(TAG_FLAG) $(ORG)/manylinux2014-x64:latest \
		--build-arg IMAGE=$(ORG)/manylinux2014-x64 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-x64/Dockerfile .
	rm -rf $@/imagefiles

manylinux2014-x64.test: manylinux2014-x64
	$(TEST_DOCKER) run $(RM) $(ORG)/manylinux2014-x64:latest > $(BIN)/dockcross-manylinux2014-x64 \
		&& chmod +x $(BIN)/dockcross-manylinux2014-x64
	$(BIN)/dockcross-manylinux2014-x64 -i $(ORG)/manylinux2014-x64:latest /opt/python/cp311-cp311/bin/python test/run.py

#
# manylinux2014-x86
#
manylinux2014-x86: manylinux2014-x86/Dockerfile
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/manylinux2014-x86:$(TAG) \
		-t $(ORG)/manylinux2014-x86:latest \
		--build-arg IMAGE=$(ORG)/manylinux2014-x86 \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-f manylinux2014-x86/Dockerfile .
	rm -rf $@/imagefiles

manylinux2014-x86.test: manylinux2014-x86
	$(TEST_DOCKER) run $(RM) $(ORG)/manylinux2014-x86:latest > $(BIN)/dockcross-manylinux2014-x86 \
		&& chmod +x $(BIN)/dockcross-manylinux2014-x86
	$(BIN)/dockcross-manylinux2014-x86 -i $(ORG)/manylinux2014-x86:latest /opt/python/cp311-cp311/bin/python test/run.py

#
# base-$(HOST_ARCH)
#
base-$(HOST_ARCH): Dockerfile imagefiles/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/base:latest-$(HOST_ARCH) \
		$(TAG_FLAG) $(ORG)/base:$(TAG)-$(HOST_ARCH) \
		--build-arg IMAGE=$(ORG)/base \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		.

base-$(HOST_ARCH).test: base-$(HOST_ARCH)
	$(TEST_DOCKER) run $(RM) $(ORG)/base:latest-$(HOST_ARCH) > $(BIN)/dockcross-base && chmod +x $(BIN)/dockcross-base

base: Dockerfile imagefiles/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/base:latest \
		$(TAG_FLAG) $(ORG)/base:$(TAG) \
		--build-arg IMAGE=$(ORG)/base \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		.

base.test: base
	$(TEST_DOCKER) run $(RM) $(ORG)/base:latest > $(BIN)/dockcross-base && chmod +x $(BIN)/dockcross-base

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
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/$@:latest \
		$(TAG_FLAG) $(ORG)/$@:$(TAG) \
		--build-arg ORG=$(ORG) \
		--build-arg IMAGE=$(ORG)/$@ \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		$@
	rm -rf $@/imagefiles

$(MULTIARCH_IMAGES): %: %/Dockerfile base-$(HOST_ARCH)
	mkdir -p $@/imagefiles && cp -r imagefiles $@/
	$(BUILD_DOCKER) $(BUILD_CMD) $(TAG_FLAG) $(ORG)/$@:latest-$(HOST_ARCH) \
		$(TAG_FLAG) $(ORG)/$@:$(TAG)-$(HOST_ARCH) \
		--build-arg ORG=$(ORG) \
		--build-arg IMAGE=$(ORG)/$@ \
		--build-arg HOST_ARCH=$(HOST_ARCH) \
		--build-arg VERSION=$(TAG) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		$@
	rm -rf $@/imagefiles

clean:
	for d in $(IMAGES) ; do rm -rf $$d/imagefiles ; done
	for d in $(IMAGES) ; do rm -rf $(BIN)/dockcross-$$d ; done
	for d in $(GEN_IMAGE_DOCKERFILES) ; do rm -f $$d ; done
	rm -f Dockerfile

purge: clean
# Remove all untagged images
	$(TEST_DOCKER) container ls -aq | xargs -r $(DOCKER) container rm -f
# Remove all images with organization (ex dockcross/*)
	$(BUILD_DOCKER) images --filter=reference='$(ORG)/*' --format='{{.Repository}}:{{.Tag}}' | xargs -r $(DOCKER) rmi -f

# Check bash syntax
bash-check:
	find . -type f \( -name "*.sh" -o -name "*.bash" \) -print0 | xargs -0 -P"$(shell nproc)" -I{} \
		$(SHELLCHECK) --check-sourced --color=auto --format=gcc --severity=warning --shell=bash --enable=all "{}"

#
# testing implicit rule
#
.SECONDEXPANSION:
$(addsuffix .test,$(STANDARD_IMAGES)): $$(basename $$@)
	$(TEST_DOCKER) run $(RM) $(ORG)/$(basename $@):latest > $(BIN)/dockcross-$(basename $@) \
		&& chmod +x $(BIN)/dockcross-$(basename $@)
	$(BIN)/dockcross-$(basename $@) -i $(ORG)/$(basename $@):latest python3 test/run.py $($@_ARGS)

.SECONDEXPANSION:
$(addsuffix .test,$(MULTIARCH_IMAGES) web-wasi-threads): $$(basename $$@)
	$(TEST_DOCKER) run $(RM) $(ORG)/$(basename $@):latest-$(HOST_ARCH) > $(BIN)/dockcross-$(basename $@) \
		&& chmod +x $(BIN)/dockcross-$(basename $@)
	$(BIN)/dockcross-$(basename $@) -i $(ORG)/$(basename $@):latest-$(HOST_ARCH) python3 test/run.py $($@_ARGS)

.SECONDEXPANSION:
$(addsuffix .tag-$(HOST_ARCH),$(MULTIARCH_IMAGES) web-wasi-threads web-wasm): $$(basename $$@)
	$(BUILD_DOCKER) tag $(ORG)/$(basename $@):latest-$(HOST_ARCH) \
		 $(ORG)/$(basename $@):$(TAG)-$(HOST_ARCH)

.SECONDEXPANSION:
$(addsuffix .push-$(HOST_ARCH),$(MULTIARCH_IMAGES) web-wasi-threads web-wasm): $$(basename $$@)
	$(BUILD_DOCKER) push $(ORG)/$(basename $@):latest-$(HOST_ARCH) \
		&& $(BUILD_DOCKER) push $(ORG)/$(basename $@):$(TAG)-$(HOST_ARCH)

.SECONDEXPANSION:
$(addsuffix .push,$(STANDARD_IMAGES) $(NON_STANDARD_IMAGES)): $$(basename $$@)
	$(BUILD_DOCKER) push $(ORG)/$(basename $@):latest \
		&& $(BUILD_DOCKER) push $(ORG)/$(basename $@):$(TAG)

.SECONDEXPANSION:
$(addsuffix .manifest,$(MULTIARCH_IMAGES) web-wasi-threads web-wasm): $$(basename $$@)
	if $(BUILDAH) manifest exists $(ORG)/$(basename $@); then \
		$(BUILDAH) manifest rm $(ORG)/$(basename $@); fi
	$(BUILDAH) manifest create $(ORG)/$(basename $@)
	$(BUILDAH) manifest add $(ORG)/$(basename $@) docker://$(ORG)/$(basename $@):latest-amd64
	$(BUILDAH) manifest add $(ORG)/$(basename $@) docker://$(ORG)/$(basename $@):latest-arm64

.SECONDEXPANSION:
$(addsuffix .push,$(MULTIARCH_IMAGES) web-wasi-threads web-wasm): $$(basename $$@).manifest
	$(BUILDAH) manifest push --all --format v2s2 $(ORG)/$(basename $@) docker://$(ORG)/$(basename $@):latest
	$(BUILDAH) manifest push --all --format v2s2 $(ORG)/$(basename $@) docker://$(ORG)/$(basename $@):$(TAG)

#
# testing prerequisites implicit rule
#
test.prerequisites:
	mkdir -p $(BIN)

$(addsuffix .test,base $(IMAGES)): test.prerequisites

.PHONY: base images $(IMAGES) test %.test clean purge bash-check display_images
