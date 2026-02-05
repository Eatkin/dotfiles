#!/usr/bin/env bash
# Bootstrapper for project starters
# Usage: ./bootstrap_project.sh <template_type> <project_name>

set -euo pipefail

TEMPLATE_TYPE=$1
DEST_PATH="$HOME/code/projects/$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYPROJECT_TEMPLATE="$SCRIPT_DIR/pyproject/pyproject.toml"
README_TEMPLATE="$SCRIPT_DIR/README.md"
GITIGNORE_DIR="$SCRIPT_DIR/gitignore"

if [[ -z "$TEMPLATE_TYPE" || -z "$DEST_PATH" ]]; then
    echo "Usage: $0 <template_type> <destination_path>"
    exit 1
fi

# Root folder containing your templates
TEMPLATES_DIR="$(dirname "$0")/project_starters"

TEMPLATE_PATH="$TEMPLATES_DIR/$TEMPLATE_TYPE"

if [[ ! -d "$TEMPLATE_PATH" ]]; then
    echo "Template '$TEMPLATE_TYPE' does not exist in $TEMPLATES_DIR"
    exit 1
fi

echo "Bootstrapping project '$TEMPLATE_TYPE' into $DEST_PATH..."

# Copy template folder
cp -r "$TEMPLATE_PATH" "$DEST_PATH"

# pyproject.toml
if [[ -f "$PYPROJECT_TEMPLATE" ]]; then
    echo "Copying pyproject.toml"
    cp "$PYPROJECT_TEMPLATE" "$DEST_PATH/pyproject.toml"
fi

# README
if [[ -f "$README_TEMPLATE" ]]; then
    echo "Copying README.md"
    cp "$README_TEMPLATE" "$DEST_PATH/README.md"
fi

# .gitignore
touch "$DEST_PATH/.gitignore"

for file in general.gitignore python.gitignore; do
    if [[ -f "$GITIGNORE_DIR/$file" ]]; then
        echo "Adding gitignore: $file"
        cat "$GITIGNORE_DIR/$file" >> "$DEST_PATH/.gitignore"
        echo "" >> "$DEST_PATH/.gitignore"
    fi
done

echo "Project bootstrapped! cd $DEST_PATH and start coding."

