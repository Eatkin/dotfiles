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

