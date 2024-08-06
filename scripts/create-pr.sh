#!/bin/bash
# Creates a PR for automated documentation update.
# Usage: ./scripts/create-pr.sh <image-name> <version>
# Example: ./scripts/create-pr.sh archlinux 20231010.123456

set -euo pipefail

IMAGE_NAME=${1}
VERSION=${2}

echo "Creating a PR for the automated documentation update..."
echo "Image name: ${IMAGE_NAME}"
echo "Version: ${VERSION}"

# Switch back to the current branch on exit
current_branch=$(git rev-parse --abbrev-ref HEAD)
trap 'git checkout $current_branch' EXIT

# Set up git
git config --global user.email "${GH_ACTIONS_USERNAME}@users.noreply.github.com"
git config --global user.name "${GH_ACTIONS_USERNAME}"
git config pull.rebase false

# Create a new branch
branch="automated-documentation-update-${GITHUB_RUN_ID}"
git checkout -b "$branch"

# Add changes to the branch
git add src/"${IMAGE_NAME}"/README.md

# Commit the changes
git commit \
    -m "chore(docs/${IMAGE_NAME}): Automated documentation update to version ${VERSION} [skip ci]" \
    -m "This PR updates the README file for the ${IMAGE_NAME} image to version ${VERSION}." \
    -m "Co-authored-by: Bart Venter <bartventer@outlook.com>"

# Push the changes
git push origin "$branch"

# Create a PR
pr_url=$(
    gh pr create \
        --fill \
        --label "documentation" \
        --assignee "${GITHUB_ACTOR}" \
        --reviewer "${GITHUB_ACTOR}"
)

# Extract PR number from the PR URL
pr_number=$(echo "$pr_url" | grep -o '[0-9]\+$')

# Enable auto-merge for the PR
gh pr merge "$pr_number" \
    --auto \
    --rebase \
    --delete-branch

echo "Done. Created a PR (${pr_url}) for the automated documentation update and enabled auto-merge."
