#!/bin/bash

USERNAME=${1:-vscode}
FAILED=()

echoStderr()
{
    echo "$@" 1>&2
}

check() {
    LABEL=$1
    shift
    echo -e "\n🧪 Testing $LABEL"
    if timeout 10 bash -c "$@" &>/dev/null; then 
        echo "✅  Passed!"
        return 0
    else
        echoStderr "❌ $LABEL check failed."
        FAILED+=("$LABEL")
        return 1
    fi
}

checkCommon() {
    check "OS" "[[ $(uname) == 'Linux' ]]"
    check "User" "[[ $(whoami) == $USERNAME ]]"
    check "Pacman" "pacman --version"
}

reportResults() {
    if [ ${#FAILED[@]} -ne 0 ]; then
        echoStderr -e "\n💥  Failed tests: ${FAILED[*]}"
        exit 1
    else 
        echo -e "\n💯  All passed!"
        exit 0
    fi
}