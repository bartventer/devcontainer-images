#!/bin/bash
# Creates a PR for automated documentation update.

set -euo pipefail

usage() {
	local message=$1 #Optional error message
	if [[ -n "$message" ]]; then
		echo "Error: $message"
		echo
	fi
	echo "Usage: $0 <image-name> <version>"
	echo "Example: $0 archlinux 20231010.123456"
}

IMAGE_NAME=${1:?"$(usage "Image name is required.")"}
VERSION=${2:?"$(usage "Version is required.")"}

echo "==============================================="
echo "📄 Creating a PR for the automated documentation update..."
echo "(*) Image name: ${IMAGE_NAME}"
echo "(*) Version: ${VERSION}"
echo "==============================================="

if [[ "${DRYRUN:-false}" == "true" ]]; then
	echo "DRYRUN is enabled. Skipping the PR creation."
	exit 0
fi

# Switch back to the current branch on exit
current_branch=$(git rev-parse --abbrev-ref HEAD)
trap 'git checkout $current_branch' EXIT

git config --global user.email "${GH_ACTIONS_USERNAME}@users.noreply.github.com"
git config --global user.name "${GH_ACTIONS_USERNAME}"
git config --global commit.gpgSign true
git config --global user.signingkey "${GPG_KEY_ID}"
git config pull.rebase false

branch="automated-documentation-update-${GITHUB_RUN_ID}"
git checkout -b "$branch"

git add src/"${IMAGE_NAME}"/README.md

git commit -S \
	-m "chore(docs/${IMAGE_NAME}): Automated documentation update to version ${VERSION} [skip ci]" \
	-m "This PR updates the README file for the ${IMAGE_NAME} image to version ${VERSION}." \
	-m "Co-authored-by: Bart Venter <bartventer@outlook.com>"

git push origin "$branch"

pr_url=$(
	gh pr create \
		--fill \
		--label "documentation" \
		--assignee "${GITHUB_ACTOR}" \
		--reviewer "${GITHUB_ACTOR}"
)

pr_number=$(echo "$pr_url" | grep -o '[0-9]\+$')

gh pr merge "$pr_number" \
	--auto \
	--rebase \
	--delete-branch

echo "✅ Done. Created a PR (${pr_url}) for the automated documentation update and enabled auto-merge."
echo
