#!/usr/bin/env bash

# Don't forget to actually install Vim in the first place
if ! command -v vim >/dev/null 2>&1; then
  echo "Installing vim..."
  sudo apt install -y vim
fi

if ! vim --version | grep -q '+clipboard'; then
  echo "Installing vim-gtk3 for system clipboard support..."
  sudo apt install -y vim-gtk3
fi

VIMRC_SRC="$HOME/dotfiles/vim/vimrc"
VIMRC_DEST="$HOME/.vimrc"

if [ ! -f "$VIMRC_DEST" ]; then
  cp "$VIMRC_SRC" "$VIMRC_DEST"
fi

# Neovim
if ! command -v nvim >/dev/null 2>&1; then
  echo "Installing neovim..."
  latest_json=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest")
  appimage_url=$(echo "${latest_json}" \
    | jq -r '.assets[] | select(.name | test("nvim-linux-x86_64.appimage$")) | .browser_download_url')

  if [[ -z "$appimage_url" ]]; then
    echo "❌ Could not find nvim-linux-x86_64.appimage in latest release"
    exit 1
  fi

  tmpfile=$(mktemp /tmp/nvim-appimage.XXXXXX)
  echo "Downloading to ${tmpfile}..."
  curl -L "$appimage_url" -o "$tmpfile"
  chmod +x "$tmpfile"

  mkdir -p "$HOME/.local/bin"
  mv "$tmpfile" "$HOME/.local/bin/nvim"
  echo "Neovim AppImage installed as ~/.local/bin/nvim"

  # Also clone gh copilot repo
  git clone --depth=1 https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim

  # headless install wheee
  nvim --headless +Lazy! +qa
fi

NVIM_SRC="$HOME/dotfiles/vim/nvim"
NVIM_DEST="$HOME/.config/nvim"

mkdir -p "$HOME/.config"

# Backup any existing config
if [ -L "$NVIM_DEST" ] || [ -d "$NVIM_DEST" ]; then
  echo "Backing up existing nvim config..."
  mv "$NVIM_DEST" "${NVIM_DEST}.bak.$(date +%s)"
fi

# Symlink
ln -s "$NVIM_SRC" "$NVIM_DEST"
echo "Symlinked nvim config from $NVIM_SRC to $NVIM_DEST"
