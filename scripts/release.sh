#!/usr/bin/env bash
# This script releases the image to Docker Hub.
# The script expects the image name and the repository name as arguments.
# Usage: ./scripts/release.sh <imageName> <repoName>
# Example: ./scripts/release.sh archlinux devcontainer-images

set -euo pipefail

RELEASERC_TEMPLATE="./doc/.releaserc-template.json"
RELEASERC_JSON=$(sed \
    -e "s/{{ imageName }}/$1/g" \
    -e "s/{{ repoName }}/$2/g" \
    "${RELEASERC_TEMPLATE}")

# Write the configuration to a temporary file
TEMP_CONFIG_FILE=$(mktemp -d)/.releaserc.json
echo "${RELEASERC_JSON}" >"${TEMP_CONFIG_FILE}"

echo "🚀 Starting new release for $1..."

if [[ "${CI:-false}" == "true" ]]; then
    npx semantic-release --extends "${TEMP_CONFIG_FILE}"
else
    npx semantic-release --extends "${TEMP_CONFIG_FILE}" --dry-run
fi

# Clean up
rm "${TEMP_CONFIG_FILE}"

echo "✔️ OK. New release created for $1"
