#!/usr/bin/env bash
set -e

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
