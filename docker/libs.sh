#!/bin/bash

set -e

ROOTFS="${1:-/rootfs}"
ARCH=$(uname -m)

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
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "nobody:x:65534:65534:Nobody:/:" > "$ROOTFS/etc/passwd"
