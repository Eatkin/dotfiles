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
fi

# Install snap if missing
if ! command -v snap >/dev/null 2>&1; then
    echo "Snap not found, installing snapd..."
    sudo apt update
    sudo apt install -y snapd
fi

# Load YAML parser
if ! command -v yq >/dev/null 2>&1; then
    echo "Installing yq for YAML parsing..."
    sudo snap install yq
fi

# Read setup.yaml
CORE=$(yq e '.core' setup.yaml)
VIM=$(yq e '.vim' setup.yaml)
DEV=$(yq e '.dev' setup.yaml)
CLOUD=$(yq e '.cloud' setup.yaml)
WEIRD_LANGS=$(yq e '.weird-langs' setup.yaml)
MEDIA=$(yq e '.media' setup.yaml)
LATEX=$(yq e '.latex' setup.yaml)
GAMING=$(yq e '.gaming' setup.yaml)
PERSONAL=$(yq e '.personal' setup.yaml)
REPOS=$(yq e '.repos' setup.yaml)
TEMPLATES=$(yq e '.templates' setup.yaml)
DESKTOP=$(yq e '.desktop' setup.yaml)

# Run modules based on YAML
[ "$CORE" = "true" ] && bash modules/core.sh
[ "$VIM" = "true" ] && bash modules/vim.sh
[ "$DEV" = "true" ] && bash modules/dev.sh
[ "$CLOUD" = "true" ] && bash modules/cloud.sh
[ "$WEIRD_LANGS" = "true" ] && bash modules/weird-langs.sh
exit 0
[ "$MEDIA" = "true" ] && bash modules/media.sh
[ "$LATEX" = "true" ] && bash modules/latex.sh
[ "$GAMING" = "true" ] && bash modules/gaming.sh
[ "$PERSONAL" = "true" ] && bash modules/personal.sh
[ "$REPOS" = "true" ] && bash modules/repos.sh
[ "$TEMPLATES" = "true" ] && bash modules/templates.sh
[ "$DESKTOP" = "true" ] && bash modules/desktop.sh
