#!/usr/bin/env bash
#
# core.sh — system packages for LXC bootstrap
#
# Idempotent: safe to run repeatedly.
# ───────────────────────────────────────────────

set -euo pipefail

echo ">>> [core] Updating package list..."
apt update -qq

echo ">>> [core] Installing base tools..."
apt install -y -qq \
    bat \
    btop \
    curl \
    fd-find \
    fish \
    git \
    htop \
    nano \
    ripgrep \
    sudo \
    tree \
    wget \
    zsh

# lsd — try repo first, fall back to GitHub .deb
if ! command -v lsd &>/dev/null; then
    echo ">>> [core] Installing lsd..."
    if apt install -y -qq lsd 2>/dev/null; then
        echo "    from apt"
    else
        echo "    fetching latest GitHub release..."
        LSD_DEB=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest \
            | grep "browser_download_url.*amd64.deb" \
            | cut -d: -f2- | tr -d '" ')
        if [ -n "$LSD_DEB" ]; then
            curl -fsSL "$LSD_DEB" -o /tmp/lsd.deb
            dpkg -i /tmp/lsd.deb 2>/dev/null || apt install -f -y -qq
            rm -f /tmp/lsd.deb
        else
            echo "    WARNING: could not fetch lsd .deb from GitHub"
        fi
    fi
fi
