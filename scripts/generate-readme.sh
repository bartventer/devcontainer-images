#!/usr/bin/env bash

# This script generates a README file for a specific image based on the metadata and build output.

set -euo pipefail

usage() {
	local message=$1 #Optional error message
	if [[ -n "$message" ]]; then
		echo "Error: $message"
		echo
	fi
	echo "Usage: $0 <image-name>"
	echo "Example: $0 archlinux"
	echo "Note: use DRYRUN=true to preview the README content without writing to a file."
}

IMAGE_NAME=${1:?"$(usage "Image name is required.")"}
DRYRUN=${DRYRUN:-false}

main() {
	local build_output="src/${IMAGE_NAME}/build-output.json"
	local metadata="src/${IMAGE_NAME}/metadata.json"
	local readme_template="docs/README-template.md"

	echo "==============================================="
	echo "📄 Generating README"
	echo "(*) Image name: ${IMAGE_NAME}"
	echo "(*) Dry run: ${DRYRUN}"
	echo "==============================================="
	if [[ ! -f "$readme_template" ]]; then
		echo "Error: README template not found at $readme_template."
		exit 1
	elif [[ ! -f "$metadata" ]]; then
		echo "Error: Metadata file not found at $metadata."
		exit 1
	elif [[ ! -f "$build_output" ]]; then
		echo "Error: Build output file not found at $build_output."
		exit 1
	fi

	local contributors container_os image_names features readme_content
	contributors=$(jq -r '[.contributors[] | "[\(.name)](\(.link))"] | join(", ")' "$metadata")
	container_os=$(jq -r 'if .containerOS.distribution then "OS: \(.containerOS.os), Distribution: \(.containerOS.distribution)" else .containerOS.os end' "$metadata")
	image_names=$(jq -r '.imageName | unique[] | "- `" + . + "`"' "$build_output" | tr '\n' '%')
	features=$(jq -r 'if .features | length > 0 then [.features[] | "[\(.name)](\(.documentation))"] | join(", ") else "None" end' "$metadata")

	readme_content=$(awk -v name="$(jq -r '.name' "$metadata")" \
		-v imageName="${IMAGE_NAME}" \
		-v contributors="${contributors}" \
		-v summary="$(jq -r '.summary' "$metadata")" \
		-v definitionType="$(jq -r '.definitionType' "$metadata")" \
		-v containerHostOSSupport="$(jq -r '.containerHostOSSupport | join(", ")' "$metadata")" \
		-v containerOS="${container_os}" \
		-v publishedImageArchitecture="$(jq -r '.platforms | join(", ")' "$metadata")" \
		-v languages="$(jq -r '.languages | join(", ")' "$metadata")" \
		-v imageNames="${image_names}" \
		-v features="${features}" \
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
    }' docs/README-template.md)

	if [[ "$DRYRUN" == "true" ]]; then
		echo "✔️ OK. README.md content is generated for $IMAGE_NAME."
		echo "(*) Previewing README content:"
		echo "$readme_content"
		echo
	else
		echo "✔️ OK. README.md content is generated for $IMAGE_NAME."
		echo "$readme_content" >"src/${IMAGE_NAME}/README.md"
		echo "(*) README.md file written to src/${IMAGE_NAME}/README.md."
		echo
	fi
}

main
