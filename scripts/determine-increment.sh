#!/usr/bin/env bash
# This script determines the increment type based on the commit messages.
# The script expects the current and previous commit SHAs as arguments.
# Usage: ./scripts/determine-increment.sh <current-sha> <previous-sha>

set -euo pipefail

# Get the last two commit SHAs
CONFIG_PATH=$1
CURRENT_SHA="${2:-$(git rev-parse HEAD)}"
PREVIOUS_SHA="${3:-$(git rev-parse HEAD~1)}"
if [[ ! -s "${CONFIG_PATH}/metadata.json" ]]; then
    echo "(!) Metadata file not found or empty: ${CONFIG_PATH}/metadata.json"
    exit 1
fi

# Log messages go to stderr
echo "🚀 Determining increment type..." >&2

# Get the commit messages between the two SHAs for the provided path
COMMIT_MESSAGES=$(git log --pretty=format:"%s" "$PREVIOUS_SHA".."$CURRENT_SHA" -- "$CONFIG_PATH")

# Check if the commit messages include any of the following keywords
increment_type=""
if echo "$COMMIT_MESSAGES" | grep -qE 'BREAKING CHANGE|major'; then
    increment_type="major"
elif echo "$COMMIT_MESSAGES" | grep -qE 'feat|feature|minor'; then
    increment_type="minor"
elif echo "$COMMIT_MESSAGES" | grep -qE 'fix|patch'; then
    increment_type="patch"
else
    echo "No keywords found in commit messages. Nothing to do." >&2
    exit 0
fi

# Log messages go to stderr
echo "✔️ OK. Increment type: $increment_type" >&2

# Output the increment type to stdout
echo "$increment_type"
