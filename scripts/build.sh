#!/usr/bin/env bash
# This script builds, tags, and pushes the image to the container registry.

set -euo pipefail

usage() {
	local message=$1 #Optional error message
	if [[ -n "$message" ]]; then
		echo "Error: $message"
		echo
	fi
	echo "Usage: $0 <image-name> <version>"
	echo "Example: $0 archlinux 20231010.123456"
	echo "Note: use DRYRUN=true to skip the build and push."
}

IMAGE_NAME=${1:?"$(usage "Image name is required.")"}
NEXT_VERSION=${2:?"$(usage "Version is required.")"}

DRYRUN=${DRYRUN:-false}
CR="${CR:-ghcr.io}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$(git config --get remote.origin.url | sed 's/.*://;s/.git$//')}"

if [[ ! -f "src/${IMAGE_NAME}/metadata.json" ]]; then
	echo "(!) Metadata file not found or empty: src/${IMAGE_NAME}/metadata.json"
	exit 1
fi

echo "==============================================="
echo "🚀 Running image build, tag and push"
echo "(*) Image name: ${IMAGE_NAME}"
echo "(*) Version: ${NEXT_VERSION}"
echo "(*) Container registry: ${CR}"
echo "(*) GitHub repository: ${GITHUB_REPOSITORY}"
echo "(*) Dry run: ${DRYRUN}"
echo "==============================================="

METADATA=$(jq -r '.' "src/${IMAGE_NAME}/metadata.json")
BUILD_OUTPUT="src/${IMAGE_NAME}/build-output.json"

# retry function to handle command retries
# Usage: retry <retries> <delay> <command>
retry() {
	local retries=$1 delay=$2
	shift 2 # Shift to the command
	local count=0
	until "$@"; do
		exit_code=$?
		count=$((count + 1))
		if ((count >= retries)); then
			echo "(!) Command failed after $count attempts."
			return $exit_code
		fi
		echo "(!) Command failed. Retrying in $delay seconds... ($count/$retries)"
		sleep "$delay"
	done
	return 0
}

if [[ "${DRYRUN}" == "false" ]]; then
	# devcontainer cli build command is a bit flaky, so we retry it a few times
	retry 3 10 \
		yarn devcontainer build \
		--log-level debug \
		--workspace-folder "src/${IMAGE_NAME}" \
		--image-name "${CR}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:latest" \
		--image-name "${CR}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${NEXT_VERSION}" \
		--platform "$(echo "${METADATA}" | jq -r '.platforms | join(",")')" \
		--push >"${BUILD_OUTPUT}"
else
	echo "(*) Dry run enabled. Skipping the build and push."
fi

echo "Build output (${BUILD_OUTPUT}):"
jq . "${BUILD_OUTPUT}"
echo
