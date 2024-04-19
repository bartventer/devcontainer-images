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
IMAGE_NAMES=$(jq -r '.imageName | unique[] | "- `" + . + "`"' "$BUILD_OUTPUT_FILE" | tr '\n' '%')
FEATURES=$(jq -r 'if .features | length > 0 then [.features[] | "[\(.name)](\(.documentation))"] | join(", ") else "None" end' "$METADATA_FILE")

awk -v name="$(jq -r '.name' "$METADATA_FILE")" \
    -v imageName="${IMAGE_NAME}" \
    -v contributors="${CONTRIBUTORS}" \
    -v summary="$(jq -r '.summary' "$METADATA_FILE")" \
    -v definitionType="$(jq -r '.definitionType' "$METADATA_FILE")" \
    -v containerHostOSSupport="$(jq -r '.containerHostOSSupport | join(", ")' "$METADATA_FILE")" \
    -v containerOS="${CONTAINER_OS}" \
    -v publishedImageArchitecture="$(jq -r '.platforms | join(", ")' "$METADATA_FILE")" \
    -v languages="$(jq -r '.languages | join(", ")' "$METADATA_FILE")" \
    -v imageNames="${IMAGE_NAMES}" \
    -v features="${FEATURES}" \
    '{
        gsub("{{name}}", name);
        gsub("{{imageName}}", imageName);
        gsub("{{contributors}}", contributors);
        gsub("{{summary}}", summary);
        gsub("{{definitionType}}", definitionType);
        gsub("{{containerHostOSSupport}}", containerHostOSSupport);
        gsub("{{containerOS}}", containerOS);
        gsub("{{publishedImageArchitecture}}", publishedImageArchitecture);
        gsub("{{languages}}", languages);
        gsub("{{imageNames}}", imageNames);
        gsub("{{features}}", features);
        gsub("%", "\n");
        print;
    }' doc/README-template.md >"src/${IMAGE_NAME}/README.md"

echo "✔️ OK. README.md file is generated for $IMAGE_NAME."
