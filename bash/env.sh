export PATH="$HOME/dotfiles/bin:$PATH"

# Pulumi local config
export PULUMI_CONFIG_PASSPHRASE=lsdevtest
export PULUMI_BACKEND_URL=file://`pwd`/myproj

# Data source (if module has been setup)
if [ -d "$HOME/.data-sources" ]; then
  export DATA_SOURCES_DIR="$HOME/.data-sources"
fi

