#!/usr/bin/env bash
# This script increments the version in metadata.json file.
# The script expects the increment type as an argument.
# Usage: ./scripts/bump-version.sh <increment> <config-path>
# Example: ./scripts/bump-version.sh patch src/archlinux

set -euo pipefail

INCREMENT=${1:-patch}
CONFIG_PATH=$2
if [[ ! -s "${CONFIG_PATH}/metadata.json" ]]; then
    echo "(!) Metadata file not found or empty: ${CONFIG_PATH}/metadata.json"
    exit 1
fi

# Redirect all echo statements to stderr
exec 3>&1 1>&2

echo "(*) Getting version from metadata.json..."

# Get the current version from metadata.json
CURRENT=$(jq -r '.version' "${CONFIG_PATH}/metadata.json")

# Increment the version
VERSION=$(semver -i "$INCREMENT" "$CURRENT")

# Update the version in metadata.json
jq --indent 4 \
    --arg VERSION "$VERSION" \
    '.version = $VERSION' \
    "${CONFIG_PATH}"/metadata.json >"${CONFIG_PATH}"/metadata.json.tmp

# mv metadata.json.tmp metadata.json
mv "${CONFIG_PATH}"/metadata.json.tmp "${CONFIG_PATH}"/metadata.json

echo "✔️ OK. Updated VERSION file with new version ($VERSION)."
echo "Version: $VERSION"
echo "Current: $CURRENT"
echo "Increment: $INCREMENT"
echo "metadata.json:"
cat metadata.json

# Output the new version to stdout
exec 1>&3
echo "$VERSION"
