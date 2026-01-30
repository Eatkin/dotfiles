#!/usr/bin/env bash

# Don't forget to actually install Vim in the first place
if ! command -v vim >/dev/null 2>&1; then
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

