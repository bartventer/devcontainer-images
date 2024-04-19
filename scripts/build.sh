#!/usr/bin/env bash
# This script builds, tags, and pushes the image to the container registry.
# The script expects the image name and the path to the configuration directory as arguments.
# Usage: ./scripts/build.sh <image-name> <config-path>
# Example: ./scripts/build.sh devcontainer-images/archlinux src/archlinux

set -euo pipefail

IMAGE_NAME=$1
VERSION=$2
DRYRUN="${3:-false}"

CR="${CR:-ghcr.io}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$(git config --get remote.origin.url | sed 's/.*://;s/.git$//')}"

if [[ -z "${IMAGE_NAME}" ]]; then
    echo "(!) Image name not provided"
    exit 1
elif [[ ! -f "src/${IMAGE_NAME}/metadata.json" ]]; then
    echo "(!) Metadata file not found or empty: src/${IMAGE_NAME}/metadata.json"
    exit 1
elif [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "(!) Invalid version provided: ${VERSION}"
    exit 1
fi

METADATA=$(jq -r '.' "src/${IMAGE_NAME}/metadata.json")
VERSION_MAJOR=$(echo "$VERSION" | cut -d. -f1)
VERSION_MINOR=$(echo "$VERSION" | cut -d. -f2)
VERSION_PATCH=$(echo "$VERSION" | cut -d. -f3)

echo "(*) Running image build, tag and push for ${IMAGE_NAME} version ${VERSION}"
BUILD_OUTPUT="src/${IMAGE_NAME}/build-output.json"
if [ "${DRYRUN}" = "false" ]; then
    devcontainer build \
        --log-level debug \
        --workspace-folder "src/${IMAGE_NAME}" \
        --image-name "${CR}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:latest" \
        --image-name "${CR}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${VERSION}" \
        --image-name "${CR}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${VERSION_MAJOR}" \
        --image-name "${CR}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${VERSION_MAJOR}.${VERSION_MINOR}" \
        --image-name "${CR}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}" \
        --platform "$(echo "${METADATA}" | jq -r '.platforms | join(",")')" \
        --push >"${BUILD_OUTPUT}"

    # Generate updated readme
    ./scripts/generate-readme.sh "${IMAGE_NAME}"

    # Create PR for the updated documentation
    ./scripts/create-pr.sh "${IMAGE_NAME}"

else
    echo "(*) Dry run enabled. Skipping the build and push."
fi

echo "✔️ OK. Image built, tagged and pushed to the registry."
echo "Build output (${BUILD_OUTPUT}):"
jq . "${BUILD_OUTPUT}"
