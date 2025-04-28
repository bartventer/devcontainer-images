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
	echo "(!) Error: File '$CONFIG' does not exist."
	exit 1
fi

DRYRUN=${DRYRUN:-false}

echo "(*) Checking for features in $CONFIG..."
features_count=$(jq -e '.features | objects | length' "$CONFIG" 2>/dev/null || echo "0")
if ((features_count == 0)); then
	echo "(!) No features found in $CONFIG. Skipping upgrade."
	exit 0
fi

preview_lockfile() {
	local message="$1" lockfile
	lockfile="$(dirname "$CONFIG")/devcontainer-lock.json"
	if [[ -f "$lockfile" ]]; then
		[[ -n "$message" ]] && echo "(*) $message"
		echo "(!) Lockfile found: $lockfile"
		echo "(!) Contents:"
		cat "$lockfile"
	else
		echo "(*) No existing lockfile found."
	fi
}

echo "==============================================="
echo "🔄 Upgrading devcontainer lockfile..."
echo "(*) Config file: $(realpath "$CONFIG")"
echo "(*) Features count: $features_count"
echo "(*) Dry run: $DRYRUN"
echo "==============================================="

[[ "$DRYRUN" == "false" ]] && preview_lockfile "Before upgrade"

yarn devcontainer upgrade \
	--workspace-folder "$(dirname "$CONFIG")" \
	--config "$CONFIG" --log-level debug --dry-run "$DRYRUN" || {
	echo "❌ Failed to upgrade lockfile for $CONFIG"
	exit 1
}

[[ "$DRYRUN" == "false" ]] && preview_lockfile "After upgrade"

echo
echo "✅ Lockfile upgrade completed successfully."
