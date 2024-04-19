#!/bin/bash
# This script creates a PR for the automated documentation update.
# The script expects the image name as an argument.
# Usage: ./scripts/create-pr.sh <image-name>
# Example: ./scripts/create-pr.sh archlinux

set -euo pipefail

IMAGE_NAME=${1}

echo "Creating a PR for the automated documentation update..."

# Set up git
git config --global user.email "${GH_ACTIONS_USERNAME}@users.noreply.github.com"
git config --global user.name "${GH_ACTIONS_USERNAME}"
git config pull.rebase false

# Create a new branch
branch="automated-documentation-update-${GITHUB_RUN_ID}"
git checkout -b "$branch"

# Add changes to the branch
git add \
    src/"${IMAGE_NAME}"/README.md \
    src/"${IMAGE_NAME}"/metadata.json

# Commit the changes
git commit -m "chore(docs/${IMAGE_NAME}): Automated documentation update [skip ci]"

# Push the changes
git push origin "$branch"

# Create a PR
gh pr create \
    --title "chore(docs/${IMAGE_NAME}): Automated documentation update" \
    --body "Automated documentation update for ${IMAGE_NAME}." \
    --label "documentation" \
    --assignee "${GH_ACTOR}" \
    --reviewer "${GH_ACTOR}"

echo "OK. Created a PR for the automated documentation update."
