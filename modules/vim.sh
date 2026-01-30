#!/usr/bin/env bash

# Vim
if ! vim --version | grep -q '+clipboard'; then
    echo "Installing vim-gtk3 for system clipboard support..."
    sudo apt install -y vim-gtk3
fi

VIMRC_SRC="$HOME/dotfiles/vim/vimrc"
VIMRC_DEST="$HOME/.vimrc"

if [ ! -f "$VIMRC_DEST" ]; then
    cp "$VIMRC_SRC" "$VIMRC_DEST"
fi

