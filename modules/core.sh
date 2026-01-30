#!/usr/bin/env bash

set -e

# Git core setup
GITCONFIG_SRC="$HOME/dotfiles/git/gitconfig"
GITCONFIG_DEST="$HOME/.gitconfig"

if [ ! -f "$GITCONFIG_DEST" ]; then
    cp "$GITCONFIG_SRC" "$GITCONFIG_DEST"
    echo "Installed global gitconfig"
else
    echo "Global gitconfig already exists"
fi

# System installs (ignore missing packages)
echo "Installing core utilities..."
CORE_PACKAGES=(jq ripgrep curl wget bat tree htop ruby libfuse2 p7zip-full)
for pkg in "${CORE_PACKAGES[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        if ! sudo apt install -y "$pkg"; then
            echo "Could not install $pkg via apt"
        fi
    fi
done

# fd-find special case
if ! command -v fdfind >/dev/null 2>&1; then
    sudo apt install -y fd-find || echo "Could not install fd-find"
fi

# Install lolcat (gem)
if ! command -v lolcat >/dev/null 2>&1; then
    sudo gem install lolcat
fi

mkdir -p ~/dotfiles/bin

# Symlink fd if using fd-find
if command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(which fdfind)" ~/dotfiles/bin/fd
fi

# Symlink batcat to bat
if command -v batcat >/dev/null 2>&1; then
    ln -sf "$(which batcat)" ~/dotfiles/bin/bat
fi


# Glow: fallback to GitHub if apt fails
if ! command -v glow >/dev/null 2>&1; then
    echo "Glow not found via apt, downloading latest release..."
    mkdir -p ~/bin
    RELEASE_URL=$(curl -s https://api.github.com/repos/charmbracelet/glow/releases/latest \
    | jq -r '.assets[] | select(.name | test("amd64.deb$")) | .browser_download_url')
    if [ -z "$RELEASE_URL" ]; then
        echo "Could not find amd64 deb for glow"
        exit 1
    fi
    wget -O ~/glow.deb "$RELEASE_URL"
    sudo dpkg -i ~/glow.deb || sudo apt -f install -y
    rm ~/glow.deb
fi

# Test glow
glow --version || echo "Glow setup failed!"

