#!/bin/bash
cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
source test-utils.sh

# Run common tests
checkCommon

check "go" "go version"
check "golangci-lint version" golangci-lint --version
check "goreleaser version" "goreleaser --version"
check "cobra-cli is installed at correct path" bash -c "which cobra-cli | grep /go/bin/cobra-cli"

# Report results
reportResults
