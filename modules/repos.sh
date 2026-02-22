#!/usr/bin/env bash
set -e

# gh auth status will exit with code 1 if no auth
if ! gh auth status >/dev/null 2>&1; then
    echo "GH CLI not authenticated. Run: gh auth login"
    exit 1
fi

REPOS=(
    "git@github.com:Eatkin/unified-site.git"
    "git@github.com:Eatkin/portfolio-page-2.git"
    "git@github.com:Eatkin/writing.git"
    "git@github.com:Eatkin/journal"
    "git@github.com:Eatkin/pokemon_db.git"
    "git@github.com:Eatkin/manga_scraper.git"
    "git@github.com:Eatkin/hero_quests.git"
    "git@github.com:Eatkin/joblens.git"
    "git@github.com:Eatkin/cv_pipeline.git"
    "git@github.com:Eatkin/chaos-workout-planner.git"
    "git@github.com:Eatkin/juggling-planner.git"
)

CODE_DIR="$HOME/code"
REPO_DIR="$CODE_DIR/private"

mkdir -p $REPO_DIR

for repo in "${REPOS[@]}"; do
    REPO_NAME=$(basename "$repo" .git)
    DEST="$REPO_DIR/$REPO_NAME"
    # Clone or update
    if [ ! -d "$DEST" ]; then
        echo "Downloading repo $REPO_NAME..."
        git clone "$repo" "$DEST" || echo "Failed to clone $repo"
    else
        echo "Pulling latest release for repo $REPO_NAME..."
        git -C "$DEST" pull || echo "Failed to pull $REPO_NAME"
    fi
done

# Actively working on projects :)
PROJECTS=(
    "git@github.com:Eatkin/aws-serverless-ingestion-architecture.git"
    "git@github.com:Eatkin/PiAudiobook.git"
)

CODE_DIR="$HOME/code"
REPO_DIR="$CODE_DIR/projects"

mkdir -p $REPO_DIR

for repo in "${PROJECTS[@]}"; do
    REPO_NAME=$(basename "$repo" .git)
    DEST="$REPO_DIR/$REPO_NAME"
    # Clone or update
    if [ ! -d "$DEST" ]; then
        echo "Downloading repo $REPO_NAME..."
        git clone "$repo" "$DEST" || echo "Failed to clone $repo"
    else
        echo "Pulling latest release for repo $REPO_NAME..."
        git -C "$DEST" pull || echo "Failed to pull $REPO_NAME"
    fi
done

