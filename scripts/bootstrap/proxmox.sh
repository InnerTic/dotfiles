#!/usr/bin/env sh
# Bootstrap — Proxmox host profile
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_LABEL="proxmox"

. "$SCRIPT_DIR/lib/common.sh"

MODULES="20-shell.sh 30-git.sh 60-ssh.sh 70-gnupg.sh"
. "$SCRIPT_DIR/lib/runner.sh"
