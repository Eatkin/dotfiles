#!/usr/bin/env bash
set -e

if ! sudo -v; then
    echo "You need sudo privileges to run this bootstrap script."
    exit 1
fi

echo "Bootstrap starting..."
echo "Edit setup.yaml to enable components."

BASHRC="$HOME/.bashrc"
MARKER_START="# >>> dotfiles bootstrap >>>"
MARKER_END="# <<< dotfiles bootstrap <<<"

BLOCK=$(cat <<'EOF'
# >>> dotfiles bootstrap >>>
[ -f "$HOME/dotfiles/bash/bashrc.sh" ] && source "$HOME/dotfiles/bash/bashrc.sh"
# <<< dotfiles bootstrap <<<
EOF
)

if [ ! -f "$BASHRC" ]; then
  touch "$BASHRC"
fi

# Don't do this twice
if ! grep -q "dotfiles/bash/bashrc.sh" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "$BLOCK" >> "$BASHRC"
  echo "Added dotfiles bootstrap to .bashrc"
else
  echo "Dotfiles bootstrap already present in .bashrc"
fi


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
CORE_PACKAGES=(jq ripgrep fd-find curl wget bat tree htop ruby)
for pkg in "${CORE_PACKAGES[@]}"; do
    if ! sudo apt install -y "$pkg"; then
        echo "Could not install $pkg via apt"
    fi
done

# Install lolcat (gem)
if ! command -v lolcat >/dev/null 2>&1; then
    sudo gem install lolcat
fi

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
