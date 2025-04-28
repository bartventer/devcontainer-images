#!/bin/bash
cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
# shellcheck source=../../../scripts/test-utils.sh
source test-utils.sh

# Run common tests
checkCommon

check "docker-daemon-check" bash -c "./_docker_daemon_check.sh"
check "version" docker --version
check "docker-init-exists" bash -c "ls /usr/local/share/docker-init.sh"

check "log-exists" bash -c "ls /tmp/dockerd.log"
check "log-for-completion" bash -c "cat /tmp/dockerd.log | grep 'Daemon has completed initialization'"
check "log-contents" bash -c "cat /tmp/dockerd.log | grep 'API listen on /var/run/docker.sock'"

# Report results
reportResults
