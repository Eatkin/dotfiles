#!/usr/bin/env bash
set -e

DEST_BIN="$HOME/dotfiles/bin"
mkdir -p "$DEST_BIN"

CORE_PACKAGES=(mpv ffmpeg)
echo "Installing core media packages..."
for pkg in "${CORE_PACKAGES[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        sudo apt install -y "$pkg" || echo "Warning: Could not install $pkg, continuing..."
    fi
done

# Ensure pipx exists
if ! command -v pipx >/dev/null 2>&1; then
    sudo apt install -y pipx
    pipx ensurepath
fi

# yt-dlp via pipx
if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "Installing yt-dlp via pipx..."
    pipx install yt-dlp
fi

MEDIA_OPTIONAL=$(yq e '.media-optional' setup.yaml)

if [ "$MEDIA_OPTIONAL" = "false" ]; then
    exit 0
fi

echo "Installing optional media packages..."

OPTIONAL_APPS=(krita gimp audacity)
for app in "${OPTIONAL_APPS[@]}"; do
    if ! command -v "$app" >/dev/null 2>&1; then
        sudo apt install -y "$app" || echo "Warning: Could not install $app, continuing..."
    fi
done
