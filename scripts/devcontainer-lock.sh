#!/usr/bin/env bash

# This script upgrades the devcontainer lockfile for a specific devcontainer.json file.

set -euo pipefail

usage() {
	local message=$1 #Optional error message
	if [[ -n "$message" ]]; then
		echo "Error: $message"
		echo
	fi
	echo "Usage: $0 <path-to-devcontainer.json>"
	echo "Example: $0 src/archlinux/devcontainer.json"
	echo "Note: use DRYRUN=true to preview the changes without applying them."
}

CONFIG=${1:?"$(usage "Path to devcontainer.json is required.")"}
if [[ ! -f "$CONFIG" ]]; then
	echo "Error: File '$CONFIG' does not exist."
	exit 1
fi

DRYRUN=${DRYRUN:-false}

echo "==============================================="
echo "🔄 Upgrading devcontainer lockfile..."
echo "(*) Config file: $CONFIG"
echo "(*) Dry run: $DRYRUN"
echo "==============================================="

echo "Checking for features in $CONFIG..."
if jq -e '.features | type == "object" and length > 0' "$CONFIG" >/dev/null; then
	echo "OK. Found features in $CONFIG, proceeding with upgrade"
else
	echo "(!) No features found in $CONFIG. Skipping upgrade."
	exit 0
fi

devcontainer upgrade \
	--workspace-folder "$(dirname "$CONFIG")" \
	--config "$CONFIG" --dry-run "$DRYRUN" || {
	echo "❌ Failed to upgrade lockfile for $CONFIG"
	exit 1
}

echo "✅ Lockfile upgrade completed successfully."
echo
