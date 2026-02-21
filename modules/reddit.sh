#!/usr/bin/env bash
set -e

echo "Installing reddit packages..."

REPO="git@github.com:Eatkin/reddit-cli.git"
REPO_DIR="$HOME/.reddit"
mkdir -p "$REPO_DIR"
REPO_NAME=$(basename "$REPO" .git)
DEST="$REPO_DIR/$REPO_NAME"
# Clone or update
if [ ! -d "$DEST" ]; then
  echo "Downloading repo $REPO_NAME..."
  git clone "$REPO" "$DEST" || echo "Failed to clone $REPO"

  # Additional setup for venv etc
  (
    # Redefine vars cause subshell
    REPO="git@github.com:Eatkin/reddit-cli.git"
    REPO_DIR="$HOME/.reddit"
    REPO_NAME=$(basename "$REPO" .git)
    DEST="$REPO_DIR/$REPO_NAME"
    cd "$DEST" || exit
    python3 -m venv venv
    source venv/bin/activate
    pip install -e . || true
)
else
  echo "Pulling latest release for repo $REPO_NAME..."
  git -C "$DEST" pull || echo "Failed to pull $REPO_NAME"
fi
