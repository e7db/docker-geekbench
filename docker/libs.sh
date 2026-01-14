#!/bin/bash

set -e

ROOTFS="${1:-/rootfs}"
VERSION="${2:-}"
ARCH=$(uname -m)

# Extract major version (e.g., "6" from "6.4.0")
MAJOR_VERSION="${VERSION%%.*}"

# Versions 2-4 need libstdc++, versions 5+ don't
needs_libstdcpp() {
    [[ -z "$MAJOR_VERSION" ]] || [[ "$MAJOR_VERSION" -lt 5 ]]
}

# Versions 2-3 on x86_64 need 32-bit libs (64-bit disabled in tryout mode)
needs_32bit_libs() {
    [[ "$ARCH" == "x86_64" ]] && [[ -n "$MAJOR_VERSION" ]] && [[ "$MAJOR_VERSION" -lt 4 ]]
}

mkdir -p "$ROOTFS/lib" "$ROOTFS/lib64" "$ROOTFS/etc"

case "$ARCH" in
    x86_64)
        mkdir -p "$ROOTFS/lib/x86_64-linux-gnu"
        cp /lib64/ld-linux-x86-64.so.2 "$ROOTFS/lib64/"
        cp /lib/x86_64-linux-gnu/libc.so.6 \
           /lib/x86_64-linux-gnu/libm.so.6 \
           /lib/x86_64-linux-gnu/libgcc_s.so.1 \
           /lib/x86_64-linux-gnu/libpthread.so.0 \
           /lib/x86_64-linux-gnu/libdl.so.2 \
           /lib/x86_64-linux-gnu/librt.so.1 \
           "$ROOTFS/lib/x86_64-linux-gnu/"
        if needs_libstdcpp; then
            cp /lib/x86_64-linux-gnu/libstdc++.so.6 "$ROOTFS/lib/x86_64-linux-gnu/"
        fi
        # v2-3 need 32-bit libs (64-bit disabled in tryout mode)
        if needs_32bit_libs; then
            mkdir -p "$ROOTFS/lib/i386-linux-gnu"
            cp /lib/ld-linux.so.2 "$ROOTFS/lib/"
            cp /lib/i386-linux-gnu/libc.so.6 \
               /lib/i386-linux-gnu/libm.so.6 \
               /lib/i386-linux-gnu/libgcc_s.so.1 \
               /lib/i386-linux-gnu/libpthread.so.0 \
               /lib/i386-linux-gnu/libdl.so.2 \
               /lib/i386-linux-gnu/librt.so.1 \
               /lib/i386-linux-gnu/libstdc++.so.6 \
               "$ROOTFS/lib/i386-linux-gnu/"
        fi
        ;;
    aarch64)
        mkdir -p "$ROOTFS/lib/aarch64-linux-gnu"
        cp /lib/ld-linux-aarch64.so.1 "$ROOTFS/lib/"
        cp /lib/aarch64-linux-gnu/libc.so.6 \
           /lib/aarch64-linux-gnu/libm.so.6 \
           /lib/aarch64-linux-gnu/libgcc_s.so.1 \
           /lib/aarch64-linux-gnu/libpthread.so.0 \
           /lib/aarch64-linux-gnu/libdl.so.2 \
           /lib/aarch64-linux-gnu/librt.so.1 \
           "$ROOTFS/lib/aarch64-linux-gnu/"
        if needs_libstdcpp; then
            cp /lib/aarch64-linux-gnu/libstdc++.so.6 "$ROOTFS/lib/aarch64-linux-gnu/"
        fi
        ;;
    armv7l)
        mkdir -p "$ROOTFS/lib/arm-linux-gnueabihf"
        cp /lib/ld-linux-armhf.so.3 "$ROOTFS/lib/"
        cp /lib/arm-linux-gnueabihf/libc.so.6 \
           /lib/arm-linux-gnueabihf/libm.so.6 \
           /lib/arm-linux-gnueabihf/libgcc_s.so.1 \
           /lib/arm-linux-gnueabihf/libpthread.so.0 \
           /lib/arm-linux-gnueabihf/libdl.so.2 \
           /lib/arm-linux-gnueabihf/librt.so.1 \
           "$ROOTFS/lib/arm-linux-gnueabihf/"
        if needs_libstdcpp; then
            cp /lib/arm-linux-gnueabihf/libstdc++.so.6 "$ROOTFS/lib/arm-linux-gnueabihf/"
        fi
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Copy tini for proper signal handling
mkdir -p "$ROOTFS/sbin"
cp /usr/bin/tini "$ROOTFS/sbin/tini"

echo "nobody:x:65534:65534:Nobody:/:" > "$ROOTFS/etc/passwd"
