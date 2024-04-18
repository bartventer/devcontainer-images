#!/usr/bin/env bash
# This script determines the increment type based on the commit messages.
# The script expects the path to the configuration file and optionally the previous and current commit SHAs as arguments.
# Usage: ./scripts/determine-increment.sh <config-path> [<previous-sha> <current-sha>]

set -euo pipefail

# Path to the configuration file
CONFIG_PATH=$1
# Previous commit SHA. Defaults to the latest commit on the branch specified by GITHUB_REF_NAME in the remote repository, or 'master' if GITHUB_REF_NAME is not set.
PREVIOUS_SHA=${2:-$(git log "origin/${GITHUB_REF_NAME:-master}" --pretty=format:'%H' -n 1)}
# Current commit SHA. Defaults to the latest commit in the local repository.
CURRENT_SHA=${3:-$(git log --pretty=format:'%H' -n 1)}

# Redirect all echo statements to stderr
exec 3>&1 1>&2

if [[ ! -s "${CONFIG_PATH}/metadata.json" ]]; then
    echo "(!) Metadata file not found or empty: ${CONFIG_PATH}/metadata.json"
    exit 1
fi

# Log messages go to stderr
echo "🚀 Determining increment type..."

# Get the commit messages between the two SHAs for the provided path
COMMIT_MESSAGES=$(git log --pretty=format:"%s" "$PREVIOUS_SHA".."$CURRENT_SHA" -- . "$CONFIG_PATH")

# If there are no commit messages, exit the script
if [ -z "$COMMIT_MESSAGES" ]; then
    echo "No commits affecting '$CONFIG_PATH' directory. Nothing to do."
    exit 0
fi

# Check if the commit messages include any of the following keywords
increment_type="patch"
if echo "$COMMIT_MESSAGES" | grep -qE 'BREAKING CHANGE'; then
    increment_type="major"
elif echo "$COMMIT_MESSAGES" | grep -qE '^feat(\(.+\))?:'; then
    increment_type="minor"
fi

# Log messages go to stderr
echo "✔️ OK. Increment type: $increment_type"
echo "📝 Commit messages:"
echo "$COMMIT_MESSAGES"

# Output the increment type to stdout
exec 1>&3
echo "$increment_type"
