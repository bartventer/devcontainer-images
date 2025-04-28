#!/bin/bash
cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
# shellcheck source=../../../scripts/test-utils.sh
source test-utils.sh

# Run common tests
checkCommon

check "Neovim" "nvim --version"

# Report results
reportResults
