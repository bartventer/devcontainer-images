#!/bin/bash
cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
source test-utils.sh

# Run common tests
checkCommon

check "curl" "curl --version"
check "git" "git --version"
check "zsh" "zsh --version"
check "Oh My Zsh! theme" "test -e \"$HOME/.oh-my-zsh/custom/themes/devcontainers.zsh-theme\""
check "zsh theme symlink" "test -e \"$HOME/.oh-my-zsh/custom/themes/codespaces.zsh-theme\""

check "go" "go version"
check "node" "node --version"
check "npm" "npm --version"
check "yarn" "yarn --version"
check "make" "make --version"
check "jq" "jq --version"
check "yq" "yq --version"

# Report results
reportResults