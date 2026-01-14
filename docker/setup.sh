#!/bin/bash

if [ -z "$VERSION" ]; then
    echo "VERSION is not set"
    exit 1
fi

error() {
    echo "Error: $1"
    exit 1
}

MAJOR_VERSION=${VERSION%.*.*}
if [ "$(uname -m)" = "armv7l" ]; then
    EXECUTABLE=geekbench_armv7
    GEEKBENCH_ARCHIVE="Geekbench-${VERSION}-LinuxARMPreview.tar.gz"
elif [ "$(uname -m)" = "aarch64" ]; then
    EXECUTABLE=geekbench_aarch64
    GEEKBENCH_ARCHIVE="Geekbench-${VERSION}-LinuxARMPreview.tar.gz"
elif [ "$(uname -m)" = "x86_64" ]; then
    EXECUTABLE=geekbench_x86_64
    GEEKBENCH_ARCHIVE="Geekbench-${VERSION}-Linux.tar.gz"
else
    error "Unsupported architecture"
fi

wget -O /tmp/${GEEKBENCH_ARCHIVE} https://cdn.geekbench.com/${GEEKBENCH_ARCHIVE}
tar -xvf /tmp/${GEEKBENCH_ARCHIVE} -C /tmp
FOLDER=$(find /tmp -type f -name 'geekbench*' -print -quit | xargs -n 1 dirname)
mv "${FOLDER}" /opt/geekbench
rm -rf /tmp/*

if [ ! -f "/opt/geekbench/${EXECUTABLE}" ]; then
    error "Failed to extract Geekbench"
fi

# Create entrypoint symlink to the architecture-specific executable
ln -sf "${EXECUTABLE}" /opt/geekbench/entrypoint
