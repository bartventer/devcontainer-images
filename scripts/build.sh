#!/usr/bin/env bash
# This script builds, tags, and pushes the image to the container registry.
# The script expects the image name and the path to the configuration directory as arguments.
# Usage: ./scripts/build.sh <image-name> <config-path>
# Example: ./scripts/build.sh devcontainer-images/archlinux src/archlinux

set -euo pipefail

IMAGE_NAME=$1
CONFIG_PATH="${2:-.}"
if [[ $CONFIG_PATH == "." ]]; then
    CONFIG_PATH=$(pwd)
fi
DRYRUN="${3:-false}"

CR="${CR:-ghcr.io}"
NAMESPACE="${NAMESPACE:-${GITHUB_REPOSITORY_OWNER}}"

if [[ -z "${IMAGE_NAME}" ]]; then
    echo "(!) Image name not provided"
    exit 1
elif [[ ! -s "${CONFIG_PATH}/metadata.json" ]]; then
    echo "(!) Metadata file not found or empty: ${CONFIG_PATH}/metadata.json"
    exit 1
fi

METADATA=$(jq -r '.' "${CONFIG_PATH}/metadata.json")
VERSION=$(echo "$METADATA" | jq -r '.version')
if ! [[ "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "(!) Invalid version format: ${VERSION}"
    exit 1
fi
VERSION_MAJOR=$(echo "$VERSION" | cut -d. -f1)
VERSION_MINOR=$(echo "$VERSION" | cut -d. -f2)
VERSION_PATCH=$(echo "$VERSION" | cut -d. -f3)

# Get the latest version from the container registry
get_latest_version() {
    local image_name=$1
    local cr=$2
    local namespace=$3
    local latest_version
    case "${cr}" in
    ghcr.io)
        local token
        token=$(curl -s "https://ghcr.io/token?scope=repository:${namespace}/${image_name}:pull" | awk -F'"' '$0=$4')
        tags=$(curl -sSL \
            -H "Authorization: Bearer ${token}" \
            "https://ghcr.io/v2/${namespace}/${image_name}/tags/list" | jq -r '.tags[]')
        echo -e " Tags:${tags}" >&2
        latest_version=$(echo "${tags}" | grep -E '^[0-9.]+$' | sort -rV | head -n1)
        ;;
    *)
        echo "(!) Unsupported container registry: ${cr}"
        exit 1
        ;;
    esac
    echo "${latest_version}"
}

# Compare two semantic versions.
# Returns 0 if version1 is greater than version2
# Returns 1 if version1 is less than version2
# Returns 2 if version1 is equal to version2
compare_versions() {
    local version1=$1
    local version2=$2
    if [[ "${version1}" == "${version2}" ]]; then
        echo 2
    elif [[ "$(printf "%s\n" "${version1}" "${version2}" | sort -V | head -n1)" == "${version1}" ]]; then
        echo 1
    else
        echo 0
    fi
}

# Check if the version is already published
LATEST_VERSION=$(get_latest_version "${IMAGE_NAME}" "${CR}" "${NAMESPACE}")
if [[ -n "${LATEST_VERSION}" ]]; then
    echo "(*) Latest version in the registry: ${LATEST_VERSION}"
    case $(compare_versions "${VERSION}" "${LATEST_VERSION}") in
    0) echo "(*) Version ${VERSION} is greater than the latest version ${LATEST_VERSION}" ;;
    1)
        echo "(*) Version ${VERSION} is less than the latest version ${LATEST_VERSION}"
        echo "(!) Version ${VERSION} is already published. Skipping the build."
        exit 0
        ;;
    2)
        echo "(*) Version ${VERSION} is equal to the latest version ${LATEST_VERSION}"
        echo "(!) Version ${VERSION} is already published. Skipping the build."
        exit 0
        ;;
    *)
        echo "(!) Invalid version comparison result found (expected: 0, 1, or 2), got: $?"
        exit 1
        ;;
    esac
else
    echo "(*) No published version found in the registry"
fi

echo "(*) Running image build, tag and push for ${IMAGE_NAME} version ${VERSION}"
OUTPUT_FLAG=""
PLATFORM_FLAG=""
if [ "${DRYRUN}" = "false" ]; then
    OUTPUT_FLAG="--push"
    PLATFORM_FLAG="--platform $(echo "${METADATA}" | jq -r '.platforms | join(",")')"
    echo "(*) Image will be pushed to the registry"
else
    echo "(*) Dry run enabled. Image will not be pushed to the registry"
fi

# Build the image
BUILD_OUTPUT="build-output.json"
devcontainer build \
    --log-level debug \
    --workspaceFolder "src/$(basename "${CONFIG_PATH}")" \
    --image-name "${CR}/${NAMESPACE}/${IMAGE_NAME}:latest" \
    --image-name "${CR}/${NAMESPACE}/${IMAGE_NAME}:${VERSION}" \
    --image-name "${CR}/${NAMESPACE}/${IMAGE_NAME}:${VERSION_MAJOR}" \
    --image-name "${CR}/${NAMESPACE}/${IMAGE_NAME}:${VERSION_MAJOR}.${VERSION_MINOR}" \
    --image-name "${CR}/${NAMESPACE}/${IMAGE_NAME}:${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}" \
    "${PLATFORM_FLAG}" \
    ${OUTPUT_FLAG} >"${BUILD_OUTPUT}"

echo "✔️ OK. Image built, tagged and pushed to the registry. Build output: ${BUILD_OUTPUT}"
