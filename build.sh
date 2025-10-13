#!/bin/bash

DIR=$(realpath $(dirname "$0"))

function get_all_versions() {
    check_version() {
        local VERSION=$1
        local URL="https://cdn.geekbench.com/Geekbench-${VERSION}-Linux.tar.gz"
        if curl --head --silent --fail --output /dev/null --url ${URL}; then
            echo "${VERSION}"
        fi
    }
    for X in {1..6}; do
        for Y in {0..10}; do
            for Z in {0..10}; do
                check_version "${X}.${Y}.${Z}" &
            done
        done
    done
    wait
}

function to_docker_tags_param() {
    local VERSION=$1
    local ADDITIONAL_TAG=$2

    local TAGS="--tag ${GHCR_IMAGE}:${VERSION} --tag ${GHCR_IMAGE}:${VERSION%.*} --tag ${GHCR_IMAGE}:${VERSION%.*.*} --tag ${DOCKERHUB_IMAGE}:${VERSION} --tag ${DOCKERHUB_IMAGE}:${VERSION%.*} --tag ${DOCKERHUB_IMAGE}:${VERSION%.*.*}"

    if [ ! -z "${ADDITIONAL_TAG}" ]; then
        TAGS="${TAGS} --tag ${GHCR_IMAGE}:${ADDITIONAL_TAG} --tag ${DOCKERHUB_IMAGE}:${ADDITIONAL_TAG}"
    fi
    echo ${TAGS}
}

function has_arm_preview() {
    local VERSION=$1
    local URL="https://cdn.geekbench.com/Geekbench-${VERSION}-LinuxARMPreview.tar.gz"
    if curl --head --silent --fail --output /dev/null --url ${URL}; then
        echo 1
    fi
}

function build_image() {
    local VERSION=$1
    local ADDITIONAL_TAG=$2

    local MAJOR_VERSION=${VERSION%.*.*}
    local TAGS=$(to_docker_tags_param ${VERSION} ${ADDITIONAL_TAG})
    local WITH_ARM_PREVIEW=$(has_arm_preview ${VERSION})
    local PLATFORMS="linux/amd64"
    if [ ! -z "${WITH_ARM_PREVIEW}" ]; then
        if [ ${MAJOR_VERSION} -eq 6 ]; then
            PLATFORMS="linux/amd64,linux/arm64"
        else
            PLATFORMS="linux/amd64,linux/arm64,linux/arm/v7"
        fi
    fi

    if ! docker buildx inspect e7db-geekbench${MAJOR_VERSION} &>/dev/null; then
        docker buildx create \
        --name e7db-geekbench${MAJOR_VERSION} \
        --platform ${PLATFORMS} \
        --use
    fi
    mkdir -p ${DIR}/build/geekbench${MAJOR_VERSION}
    docker buildx build \
        --cache-from type=registry,ref=${GHCR_IMAGE}:${MAJOR_VERSION}-cache \
        --cache-to type=registry,ref=${GHCR_IMAGE}:${MAJOR_VERSION}-cache \
        --file ${DIR}/Dockerfile \
        --metadata-file ${DIR}/build/geekbench${MAJOR_VERSION}/metadata.json \
        --output type=registry \
        --platform ${PLATFORMS} \
        --build-arg VERSION=${VERSION} \
        ${TAGS} \
        ${DIR}
}

if [[ "$*" == *--all* ]]; then
    VERSIONS=($(get_all_versions | sort -u))
else
    VERSION_REGEX='Geekbench-[0-9]+\.[0-9]+\.[0-9]+-Linux'
    LEGACY_VERSIONS=($(echo "$(curl -s https://www.geekbench.com/legacy/)" | grep -oE $VERSION_REGEX | awk -F'-' '{print $2}' | sort -u))
    LATEST_VERSION=($(echo "$(curl -s https://www.geekbench.com/download/linux/)" | grep -oE $VERSION_REGEX | awk -F'-' '{print $2}' | sort -u))
    VERSIONS=($(printf "%s\n" "${LEGACY_VERSIONS[@]} ${LATEST_VERSION[@]}" | tr ' ' '\n' | sort -t. -k1,1n -k2,2n -k3,3n))
fi

for VERSION in "${VERSIONS[@]}"; do
    unset ADDITIONAL_TAG
    if [ $VERSION == "${VERSIONS[-1]}" ]; then
        ADDITIONAL_TAG="latest"
    fi

    if [[ "$*" == *--dry-run* ]]; then
        echo build_image ${VERSION} ${ADDITIONAL_TAG}
    else
        build_image ${VERSION} ${ADDITIONAL_TAG}
    fi
done
