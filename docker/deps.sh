#!/bin/bash

set -e

VERSION="${1:-}"
MAJOR="${VERSION%%.*}"

# Versions 2-3 on x86_64 need 32-bit libs (64-bit disabled in tryout mode)
if [ "$MAJOR" -lt 4 ] 2>/dev/null; then
    dpkg --add-architecture i386
fi

apt-get update

PACKAGES="tini"

# Versions 2-4 need libstdc++, versions 5+ don't
if [ "$MAJOR" -lt 5 ] 2>/dev/null; then
    PACKAGES="$PACKAGES libstdc++6"
fi

# Versions 2-3 need 32-bit libs
if [ "$MAJOR" -lt 4 ] 2>/dev/null; then
    PACKAGES="$PACKAGES libc6:i386 libstdc++6:i386"
fi

apt-get install -y --no-install-recommends $PACKAGES
rm -rf /var/lib/apt/lists/*
