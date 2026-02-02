#!/usr/bin/env bash
set -e

echo "Configuring rss module..."

if ! command -v newsboat >/dev/null 2>&1; then
    echo "Installing newsboat..."
    sudo snap install newsboat
fi

echo "Remember to sync_data to pull url file!"
