#!/usr/bin/env sh
# Bootstrap — server profile (no sudo lecture, no fastfetch)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_LABEL="server"

. "$SCRIPT_DIR/lib/common.sh"

MODULES="20-shell.sh 30-git.sh 50-tmux.sh 60-ssh.sh 70-gnupg.sh"
. "$SCRIPT_DIR/lib/runner.sh"
