# Guard against double load
[ -n "$DOTFILES_BASH_LOADED" ] && return
export DOTFILES_BASH_LOADED=1

for f in env aliases functions; do
  [ -f "$HOME/dotfiles/bash/$f.sh" ] && source "$HOME/dotfiles/bash/$f.sh"
done

# Git completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi

# Direnv hook
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

# Miniconda PATH
if [ -d "$HOME/miniconda3/bin" ] && [[ ":$PATH:" != *":$HOME/miniconda3/bin:"* ]]; then
    export PATH="$HOME/miniconda3/bin:$PATH"
fi

# Initialise conda for shell sessions
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

# Load custom functions
if [ -f "$HOME/dotfiles/bash/functions.sh" ]; then
    source "$HOME/dotfiles/bash/functions.sh"
fi

# Setup reddit cli if available
REPO="git@github.com:Eatkin/reddit-cli.git"
REPO_DIR="$HOME/.reddit"
REPO_NAME=$(basename "$REPO" .git)
DEST="$REPO_DIR/$REPO_NAME"
if [ -d "$DEST/venv" ]; then
  # I have to do this because Textual/Asyncio completely hijack logging and dump a random app.log file wherever we are
  reddit() {
    (
        REPO_DIR="$HOME/.reddit/reddit-cli"
        cd "$REPO_DIR" || return 1  # go to repo root
        source "$REPO_DIR/venv/bin/activate"  # activate venv
        python app.py "$@"
    )
}
fi

# Disable history expand
set +o histexpand
