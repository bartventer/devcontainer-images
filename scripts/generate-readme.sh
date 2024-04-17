#!/usr/bin/env bash
# This script generates a README.md file for the image based on the template.
# The script expects the image name and version as arguments.
# Usage: ./scripts/generate-readme.sh <image-name> <major-version> <minor-version> <patch-version>

set -euxo pipefail

IMAGE_NAME=${1:-}
BUILD_OUTPUT_FILE="src/${IMAGE_NAME}/build-output.json"
METADATA_FILE="src/${IMAGE_NAME}/metadata.json"

echo "🚀 Generating README for $IMAGE_NAME"

if [[ -z "$IMAGE_NAME" ]]; then
    echo "Error: IMAGE_NAME argument is not provided."
    exit 1
elif [[ ! -f "$METADATA_FILE" ]]; then
    echo "Error: Metadata file not found at $METADATA_FILE."
    exit 1
elif [[ ! -f "$BUILD_OUTPUT_FILE" ]]; then
    echo "Error: Build output file not found at $BUILD_OUTPUT_FILE."
    exit 1
fi

# Generate markdown links for each contributor
CONTRIBUTORS=$(jq -r '[.contributors[] | "[\(.name)](\(.link))"] | join(", ")' "$METADATA_FILE")
CONTAINER_OS=$(jq -r 'if .containerOS.distribution then "OS: \(.containerOS.os), Distribution: \(.containerOS.distribution)" else .containerOS.os end' "$METADATA_FILE")
IMAGE_NAMES=$(jq -r '.imageName[] | "- `" + . + "`"' "$BUILD_OUTPUT_FILE" | tr '\n' '@')

# Replace placeholders in the template with the actual values
sed -e "s/{{name}}/$(jq -r '.name' "$METADATA_FILE")/g" \
    -e "s/{{imageName}}/${IMAGE_NAME}/g" \
    -e "s|{{contributors}}|${CONTRIBUTORS}|g" \
    -e "s/{{summary}}/$(jq -r '.summary' "$METADATA_FILE")/g" \
    -e "s/{{definitionType}}/$(jq -r '.definitionType' "$METADATA_FILE")/g" \
    -e "s/{{containerHostOSSupport}}/$(jq -r '.containerHostOSSupport | join(", ")' "$METADATA_FILE")/g" \
    -e "s/{{containerOS}}/${CONTAINER_OS}/g" \
    -e "s/{{publishedImageArchitecture}}/$(jq -r '.platforms | join(", ")' "$METADATA_FILE")/g" \
    -e "s/{{languages}}/$(jq -r '.languages | join(", ")' "$METADATA_FILE")/g" \
    -e "s|{{imageNames}}|${IMAGE_NAMES}|g" \
    doc/README-template.md | tr '@' '\n' >"src/${IMAGE_NAME}/README.md"

echo "✔️ OK. README.md file is generated for $IMAGE_NAME."
