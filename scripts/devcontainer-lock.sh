#!/usr/bin/env bash

set -euo pipefail

echo "Upgrading the devcontainer lockfiles..."

devcontainer_dirs=$(find . -name .devcontainer -type d -print)
for dir in $devcontainer_dirs; do
    echo "Upgrading lockfiles in $dir..."
    devcontainer upgrade --workspace-folder "$dir" --config ".devcontainer/devcontainer.json"
done

echo "✅ Done upgrading the devcontainer lockfiles."
