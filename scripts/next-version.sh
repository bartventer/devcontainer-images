#!/usr/bin/env bash

# This script bumps the version in the version file, and returns the new version.
# The script expects the path to the version file as an argument.
# Usage: ./scripts/next-version.sh --version-file <version-file>
# Example: ./scripts/next-version.sh --version-file VERSION

set -euo pipefail

# Parse the flags
while [[ $# -gt 0 ]]; do
    case "$1" in
    --version-file)
        VERSION_FILE=$2
        shift
        ;;
    *)
        echo "(!) Unknown argument: $1"
        exit 1
        ;;
    esac
    shift
done

# Check if the version file exists
if [[ ! -f "${VERSION_FILE}" ]]; then
    echo "(!) Version file not found: ${VERSION_FILE}"
    exit 1
fi

# Read the current version from the file
CURRENT_VERSION=$(cat "${VERSION_FILE}")

# Bump the version
NEXT_VERSION=$(npx semver "${CURRENT_VERSION}" -i patch)

# Write the new version back to the file
echo "${NEXT_VERSION}" >"${VERSION_FILE}"

# Echo the new version
echo "${NEXT_VERSION}"
