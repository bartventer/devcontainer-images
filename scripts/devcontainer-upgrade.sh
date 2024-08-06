#!/usr/bin/env bash

set -euo pipefail

echo "Upgrading the devcontainer lockfiles..."

folders_containing_devcontainer=$(find . -name .devcontainer -type d -exec dirname {} \;)
for folder in $folders_containing_devcontainer; do
    echo "Upgrading lockfiles in $folder..."
    devcontainer upgrade --workspace-folder "$folder" --config ".devcontainer/devcontainer.json"
done

echo "✅ Done upgrading the devcontainer lockfiles."
