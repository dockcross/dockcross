dockcross image for ARMv7-A
===========================

Toolchain configured for ARMv7-A used in Beaglebone Black single board PC with TI SoC AM3358 on board, Cortex-A8. Code compiled with dockcross armv7 image crashes on Beaglebone, see https://github.com/dockcross/dockcross/issues/290

Difference with dockcross armv7 toolchain: ARCH_CPU="cortex-a8", ARCH_FPU="neon". 

Only NEON is enabled, though TI docs says it is possible to use both VFPv3 and NEON http://processors.wiki.ti.com/index.php/Using_NEON_and_VFPv3_on_Cortex-A8

I do not know how to configure CrossTool-NG for VFPv3+NEON. Feel you free to submit a fix)

