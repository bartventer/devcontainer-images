#!/usr/bin/env bash
# This script generates a README.md file for the image based on the template.
# The script expects the image name and version as arguments.
# Usage: ./scripts/generate-readme.sh <image-name> <major-version> <minor-version> <patch-version>

set -euo pipefail

IMAGE_NAME=${1:-}
VERSION_MAJOR=${2:-}
VERSION_MINOR=${3:-}
VERSION_PATCH=${4:-}
METADATA_FILE="src/${IMAGE_NAME}/metadata.json"

echo "🚀 Generating README for $IMAGE_NAME:$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

if [[ -z "$IMAGE_NAME" ]]; then
    echo "Error: IMAGE_NAME argument is not provided."
    exit 1
elif [[ -z "$VERSION_MAJOR" ]]; then
    echo "Error: VERSION_MAJOR argument is not provided."
    exit 1
elif [[ -z "$VERSION_MINOR" ]]; then
    echo "Error: VERSION_MINOR argument is not provided."
    exit 1
elif [[ -z "$VERSION_PATCH" ]]; then
    echo "Error: VERSION_PATCH argument is not provided."
    exit 1
elif [[ ! -f "$METADATA_FILE" ]]; then
    echo "Error: Metadata file not found at $METADATA_FILE."
    exit 1
fi

# Generate markdown links for each contributor
CONTRIBUTORS=$(jq -r '[.contributors[] | "[\(.name)](\(.link))"] | join(", ")' "$METADATA_FILE")

# Replace placeholders in the template with the actual values
sed -e "s/{{imageName}}/${IMAGE_NAME}/g" \
    -e "s/{{majorVersion}}/${VERSION_MAJOR}/g" \
    -e "s/{{minorVersion}}/${VERSION_MINOR}/g" \
    -e "s/{{patchVersion}}/${VERSION_PATCH}/g" \
    -e "s|{{contributors}}|${CONTRIBUTORS}|g" \
    -e "s/{{summary}}/$(jq -r '.summary' "$METADATA_FILE")/g" \
    -e "s/{{definitionType}}/$(jq -r '.definitionType' "$METADATA_FILE")/g" \
    -e "s/{{containerHostOSSupport}}/$(jq -r '.containerHostOSSupport' "$METADATA_FILE")/g" \
    -e "s/{{containerOS}}/$(jq -r '.containerOS' "$METADATA_FILE")/g" \
    doc/README-template.md >"src/${IMAGE_NAME}/README.md"

echo "✔️ OK. README.md file is generated for $IMAGE_NAME:$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"