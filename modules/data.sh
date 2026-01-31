#!/usr/bin/env bash

set -e

DATA_DIR="$HOME/.data-sources"

if [ -d "$DATA_DIR" ]; then
    echo "Data directory already exists, skipping initial sync"
    exit 0
fi

# Ensure functions loaded
source "$HOME/dotfiles/bash/functions.sh"

echo "Initial data sync (cloud → local)"
if ! sync_data pull; then
    echo "Initial data sync failed"
fi

echo "Data module initialised"

