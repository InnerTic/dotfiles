#!/usr/bin/env sh
# Bootstrap — Debian desktop profile
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_LABEL="debian"

. "$SCRIPT_DIR/lib/common.sh"

MODULES="10-sudo-lecture.sh 20-shell.sh 30-git.sh 40-fastfetch.sh 50-tmux.sh 60-ssh.sh 70-gnupg.sh"
. "$SCRIPT_DIR/lib/runner.sh"
