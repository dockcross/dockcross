#!/bin/bash
exec ${0/*${TOOLCHAIN}-/\/usr\/bin\/x86_64-linux-gnu-} -m32 "$@"
