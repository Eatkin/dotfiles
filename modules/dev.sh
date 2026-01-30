#!/usr/bin/env bash
set -e

# Direnv
if ! command -v direnv >/dev/null 2>&1; then
    sudo apt install -y direnv
fi

# GH CLI
if ! command -v gh >/dev/null 2>&1; then
    sudo apt install -y gh
    echo "You will need to run 'gh auth login' manually"
fi
