#!/usr/bin/env sh
# Bootstrap — container profile (minimal, no sudo)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_LABEL="container"

. "$SCRIPT_DIR/lib/common.sh"

MODULES="12-containers.sh 20-shell.sh 30-git.sh 60-ssh.sh 70-gnupg.sh"
. "$SCRIPT_DIR/lib/runner.sh"
