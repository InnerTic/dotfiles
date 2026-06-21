#!/usr/bin/env sh
# Bootstrap — CachyOS desktop profile
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_LABEL="cachyos"

. "$SCRIPT_DIR/lib/common.sh"

MODULES="10-sudo-lecture.sh 20-shell.sh 30-git.sh 40-fastfetch.sh 50-tmux.sh 60-ssh.sh"
. "$SCRIPT_DIR/lib/runner.sh"
