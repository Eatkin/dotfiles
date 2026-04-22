#!/usr/bin/env bash
set -e

echo "Installing dev packages..."
CORE_PACKAGES=(caffeine direnv openjdk-17-jdk maven shellcheck)
for pkg in "${CORE_PACKAGES[@]}"; do
  if ! command -v "$pkg" >/dev/null 2>&1; then
    if ! sudo apt install -y "$pkg"; then
      echo "Could not install $pkg via apt"
    fi
  fi
done

# GH CLI
if ! command -v gh >/dev/null 2>&1; then
  sudo apt install -y gh
  echo "You will need to run 'gh auth login' manually"
fi

# Python formatters/linters/etc
PYTHON=$(command -v python3 || echo python)

# Ensure pip is installed
if ! "$PYTHON" -m pip --version >/dev/null 2>&1; then
  echo "Installing pip..."
  sudo apt install -y python3-pip
fi

# Tools to install globally with pipx
PYTOOLS=(black mypy ruff pylint tldr)

for tool in "${PYTOOLS[@]}"; do
  if ! "$PYTHON" -m pip show "$tool" >/dev/null 2>&1; then
    echo "Installing $tool..."
    pipx install "$tool"
    # "$PYTHON" -m pip install --user "$tool"
  fi
done

# Node is (unfortunately) a requirement of pyright
if ! command -v node >/dev/null 2>&1; then
  echo "Installing NodeJS..."
  sudo apt install -y nodejs npm
fi

if ! command -v pyright >/dev/null 2>&1; then
  echo "Installing Pyright via npm..."
  npm install -g pyright
fi

# shfmt for bash syntax highlighting
if ! command -v shfmt >/dev/null 2>&1; then
  echo "Installing shfmt..."
  sudo apt install -y shfmt
fi

# Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker..."
  sudo apt update
  sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  # Add Docker repo
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Add current user to docker group
  sudo usermod -aG docker "$USER"
  echo "Docker installed"
fi

# ChromeDriver if desired
CHROMEDRIVER=$(yq e '.["dev-options"].chromedriver' setup.yaml)

if [ "$CHROMEDRIVER" = "true" ]; then
  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$BIN_DIR"

  if ! command -v chromedriver >/dev/null 2>&1; then
    echo "Installing ChromeDriver (stable, last-known-good)..."

    JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json"

    DRIVER_URL=$(curl -sS "$JSON_URL" | jq -r '
          .channels.stable.downloads.chromedriver[]
          | select(.platform == "linux64")
          | .url
        ')

    if [ -z "$DRIVER_URL" ] || [ "$DRIVER_URL" = "null" ]; then
      echo "Failed to determine ChromeDriver download URL"
      exit 1
    fi

    TMP_ZIP="/tmp/chromedriver-linux64.zip"

    curl -L -o "$TMP_ZIP" "$DRIVER_URL"
    unzip -o "$TMP_ZIP" -d "$BIN_DIR"
    chmod +x "$BIN_DIR/chromedriver"
    rm -f "$TMP_ZIP"

    echo "ChromeDriver installed at $BIN_DIR/chromedriver"
  fi
fi

# Cht.sh
if ! command -v "cht.sh" >/dev/null 2>&1; then
  echo "Installing cht.sh..."
  PATH_DIR="$HOME/bin"
  mkdir -p "$PATH_DIR"
  curl https://cht.sh/:cht.sh >"$PATH_DIR/cht.sh"
  chmod +x "$PATH_DIR/cht.sh"
fi

# Difftastic
if ! command -v "difft" >/dev/null 2>&1; then
  echo "Installing difftastic..."
  DIFFT_URL=$(curl -s https://api.github.com/repos/Wilfred/difftastic/releases/latest |
    grep "browser_download_url" |
    grep "difft-x86_64-unknown-linux-gnu.tar.gz" |
    cut -d '"' -f 4)
  TMPDIR=$(mktemp -d)
  curl -L "$DIFFT_URL" | tar -xz -C "$TMPDIR"
  mkdir -p "$HOME/.local/bin"
  mv "$TMPDIR/difft" "$HOME/.local/bin/difft"
  chmod +x "$HOME/.local/bin/difft"
  rm -rf "$TMPDIR"
fi

# Rust required for some stuff so if we don't have cargo install Rust
if ! command -v "cargo" >/dev/null 2>&1; then
  echo "Installing rust for cargo..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# We'll set up uv and ty here
if ! command -v "uv" >/dev/null 2>&1; then
  echo "Installing uv and ty"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  "$HOME/.local/bin/uv" tool install ty
fi
