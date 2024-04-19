#!/usr/bin/env bash
# This script releases the image to Docker Hub.
# The script expects the image name and the repository name as arguments.
# Usage: ./scripts/release.sh <imageName> <repoName>
# Example: ./scripts/release.sh archlinux devcontainer-images

set -euo pipefail

RELEASERC_TEMPLATE="./doc/.releaserc-template.json"
RELEASERC_JSON=$(sed \
    -e "s/{{ imageName }}/$1/g" \
    "${RELEASERC_TEMPLATE}")

# Backup the existing .releaserc.json file if it exists
[ -f .releaserc.json ] && cp .releaserc.json .releaserc.json.bak

# Write the configuration to .releaserc.json
echo "${RELEASERC_JSON}" >.releaserc.json

# Set a trap to restore the original .releaserc.json file when the script exits
trap '[ -f .releaserc.json.bak ] && mv .releaserc.json.bak .releaserc.json' EXIT

echo "🚀 Starting new release for $1..."

if [[ "${CI:-false}" == "true" ]]; then
    npx semantic-release
else
    npx semantic-release --dry-run
fi

echo "✔️ OK. New release created for $1"
