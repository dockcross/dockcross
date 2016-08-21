DOCKER = docker
ORG = dockcross
BIN = bin

images: base android-arm linux-x86 linux-x64 linux-arm64 linux-armv5 linux-armv6 linux-armv7 windows-x86 windows-x64

test: base.test android-arm.test linux-x86.test linux-x64.test linux-arm64.test linux-armv5.test linux-armv6.test linux-armv7.test windows-x86.test windows-x64.test

android-arm: base android-arm/Dockerfile
	$(DOCKER) build -t $(ORG)/android-arm android-arm

android-arm.test: android-arm test/run.py
	$(DOCKER) run --rm dockcross/android-arm > $(BIN)/dockcross-android-arm && chmod +x $(BIN)/dockcross-android-arm
	$(BIN)/dockcross-android-arm python test/run.py

browser-asmjs: base browser-asmjs/Dockerfile
	cp -r test browser-asmjs/
	$(DOCKER) build -t $(ORG)/browser-asmjs browser-asmjs
	rm -rf browser-asmjs/test

browser-asmjs.test: browser-asmjs test/run.py
	$(DOCKER) run --rm dockcross/browser-asmjs > $(BIN)/dockcross-browser-asmjs && chmod +x $(BIN)/dockcross-browser-asmjs
	$(BIN)/dockcross-browser-asmjs python test/run.py --exe-suffix ".js"

linux-x86: base linux-x86/Dockerfile linux-x86/Toolchain.cmake
	$(DOCKER) build -t $(ORG)/linux-x86 linux-x86

linux-x86.test: linux-x86 test/run.py
	$(DOCKER) run --rm dockcross/linux-x86 > $(BIN)/dockcross-linux-x86 && chmod +x $(BIN)/dockcross-linux-x86
	$(BIN)/dockcross-linux-x86 python test/run.py

linux-x64: base linux-x64/Dockerfile
	$(DOCKER) build -t $(ORG)/linux-x64 linux-x64

linux-x64.test: linux-x64 test/run.py
	$(DOCKER) run --rm dockcross/linux-x64 > $(BIN)/dockcross-linux-x64 && chmod +x $(BIN)/dockcross-linux-x64
	$(BIN)/dockcross-linux-x64 python test/run.py

linux-arm64: base linux-arm64/Dockerfile linux-arm64/Toolchain.cmake
	$(DOCKER) build -t $(ORG)/linux-arm64 linux-arm64

linux-arm64.test: linux-arm64 test/run.py
	$(DOCKER) run --rm dockcross/linux-arm64 > $(BIN)/dockcross-linux-arm64 && chmod +x $(BIN)/dockcross-linux-arm64
	$(BIN)/dockcross-linux-arm64 python test/run.py

linux-armv5: base linux-armv5/Dockerfile linux-armv5/Toolchain.cmake
	$(DOCKER) build -t $(ORG)/linux-armv5 linux-armv5

linux-armv5.test: linux-armv5 test/run.py
	$(DOCKER) run --rm dockcross/linux-armv5 > $(BIN)/dockcross-linux-armv5 && chmod +x $(BIN)/dockcross-linux-armv5
	$(BIN)/dockcross-linux-armv5 python test/run.py

linux-armv6: base linux-armv6/Dockerfile linux-armv6/Toolchain.cmake
	$(DOCKER) build -t $(ORG)/linux-armv6 linux-armv6

linux-armv6.test: linux-armv6 test/run.py
	$(DOCKER) run --rm dockcross/linux-armv6 > $(BIN)/dockcross-linux-armv6 && chmod +x $(BIN)/dockcross-linux-armv6
	$(BIN)/dockcross-linux-armv6 python test/run.py

linux-armv7: base linux-armv7/Dockerfile linux-armv7/Toolchain.cmake
	$(DOCKER) build -t $(ORG)/linux-armv7 linux-armv7

linux-armv7.test: linux-armv7 test/run.py
	$(DOCKER) run --rm dockcross/linux-armv7 > $(BIN)/dockcross-linux-armv7 && chmod +x $(BIN)/dockcross-linux-armv7
	$(BIN)/dockcross-linux-armv7 python test/run.py

linux-ppc64le: base linux-ppc64le/Dockerfile linux-ppc64le/Toolchain.cmake
	$(DOCKER) build -t $(ORG)/linux-ppc64le linux-ppc64le

linux-ppc64le.test: linux-ppc64le test/run.py
	$(DOCKER) run --rm dockcross/linux-ppc64le > $(BIN)/dockcross-linux-ppc64le && chmod +x $(BIN)/dockcross-linux-ppc64le
	$(BIN)/dockcross-linux-ppc64le python test/run.py --languages C

windows-x86: base windows-x86/Dockerfile windows-x86/settings.mk
	$(DOCKER) build -t $(ORG)/windows-x86 windows-x86

windows-x86.test: windows-x86 test/run.py
	$(DOCKER) run --rm dockcross/windows-x86 > $(BIN)/dockcross-windows-x86 && chmod +x $(BIN)/dockcross-windows-x86
	$(BIN)/dockcross-windows-x86 python test/run.py  --exe-suffix ".exe"

windows-x64: base windows-x64/Dockerfile windows-x64/settings.mk
	$(DOCKER) build -t $(ORG)/windows-x64 windows-x64

windows-x64.test: windows-x64 test/run.py
	$(DOCKER) run --rm dockcross/windows-x64 > $(BIN)/dockcross-windows-x64 && chmod +x $(BIN)/dockcross-windows-x64
	$(BIN)/dockcross-windows-x64 python test/run.py --exe-suffix ".exe"

xtensa-lx106.test: xtensa-lx106 test/run.py
	$(DOCKER) run --rm dockcross/xtensa-lx106 > $(BIN)/dockcross-xtensa && chmod +x $(BIN)/dockcross-xtensa
	$(BIN)/dockcross-xtensa python test/run.py

base: Dockerfile
	$(DOCKER) build -t $(ORG)/base .

base.test: base test/run.py
	mkdir -p $(BIN)
	$(DOCKER) run --rm dockcross/base > $(BIN)/dockcross-base && chmod +x $(BIN)/dockcross-base

.PHONY: images base android-arm linux-x86 linux-x64 linux-arm64 linux-armv5 linux-armv6 linux-armv7 windows-x86 windows-x64 tests %.test
