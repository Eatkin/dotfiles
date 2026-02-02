#!/usr/bin/env bash
set -e

echo "Installing dev packages..."
CORE_PACKAGES=(caffeine direnv openjdk-17-jdk maven)
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

# VSCode
if ! command -v code >/dev/null 2>&1; then
    echo "Installing VS Code..."
    wget -qO ~/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt install -y ~/vscode.deb
    rm ~/vscode.deb
fi

echo "Installing VS Code extensions..."
while read -r ext; do
    if ! code --list-extensions | grep -q "^$ext$"; then
        code --install-extension "$ext"
        echo "✓ Installed $ext"
    fi
done < ~/dotfiles/etc/vscode-extensions.txt

echo "Synchronising settings"
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
mkdir -p "$(dirname "$VSCODE_SETTINGS")"
cp ~/dotfiles/vscode/settings.json "$VSCODE_SETTINGS"

# Miniconda
if [ ! -d "$HOME/miniconda3" ]; then
    echo "Installing Miniconda..."
    wget -qO ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash ~/miniconda.sh -b -p "$HOME/miniconda3"
    rm ~/miniconda.sh
    echo "Miniconda installed"
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
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Add current user to docker group
    sudo usermod -aG docker "$USER"
    echo "Docker installed"
fi

# Chromedriver is necessary
CHROMEDRIVER=$(yq e '.["dev-options"].chromedriver' setup.yaml)

if [ "$CHROMEDRIVER" = "true" ]; then
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"

    if ! command -v chromedriver >/dev/null 2>&1; then
        echo "Installing ChromeDriver..."
        LATEST=$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
        curl -L -o /tmp/chromedriver_linux64.zip \
             "https://chromedriver.storage.googleapis.com/${LATEST}/chromedriver_linux64.zip"
        unzip -o /tmp/chromedriver_linux64.zip -d "$BIN_DIR"
        chmod +x "$BIN_DIR/chromedriver"
        rm /tmp/chromedriver_linux64.zip
        echo "ChromeDriver installed at $BIN_DIR/chromedriver"
    fi
fi
