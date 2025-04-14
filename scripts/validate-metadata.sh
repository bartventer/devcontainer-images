#!/usr/bin/env bash
# This script validates the metadata file for a specific image against a JSON schema.

set -euo pipefail
usage() {
	local message=$1 #Optional error message
	if [[ -n "$message" ]]; then
		echo "Error: $message"
		echo
	fi
	echo "Usage: $0 <image-name>"
	echo "Example: $0 archlinux"
}

IMAGE_NAME=${1:?"$(usage "Image name is required.")"}
IMAGE_METADATA="src/${IMAGE_NAME}/metadata.json"
CONFIG_SCHEMA="docs/metadata.schema.json"

if [[ ! -f "$IMAGE_METADATA" ]]; then
	echo "(!) Metadata file not found or empty: $IMAGE_METADATA"
	exit 1
fi
if [[ ! -f "$CONFIG_SCHEMA" ]]; then
	echo "(!) Schema file not found or empty: $CONFIG_SCHEMA"
	exit 1
fi

echo "==============================================="
echo "🚀 Validating image metadata"
echo "(*) Image name: ${IMAGE_NAME}"
echo "(*) Metadata file: ${IMAGE_METADATA}"
echo "(*) Schema file: ${CONFIG_SCHEMA}"
echo "==============================================="

yarn ajv validate \
	-s "$CONFIG_SCHEMA" \
	-d "$IMAGE_METADATA" \
	-c ajv-formats \
	--verbose || (echo "❌ Error. Metadata file is invalid." && exit 1)

echo "✅ OK. Metadata file is valid."
echo
