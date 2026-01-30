#!/usr/bin/env bash
set -e

DEST_BIN="$HOME/dotfiles/bin"
mkdir -p "$DEST_BIN"

CORE_PACKAGES=(mpv ffmpeg)
echo "Installing core media packages..."
for pkg in "${CORE_PACKAGES[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        sudo apt install -y "$pkg" || echo "Warning: Could not install $pkg, continuing..."
    fi
done

# Ensure pipx exists
if ! command -v pipx >/dev/null 2>&1; then
    sudo apt install -y pipx
    pipx ensurepath
fi

# yt-dlp via pipx
if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "Installing yt-dlp via pipx..."
    pipx install yt-dlp
fi

# Additional tooling from github releases
MEDIA_DIR="$HOME/code/tools"
WIN_MEDIA_DIR="$MEDIA_DIR/windows"
LINUX_MEDIA_DIR="$MEDIA_DIR/linux"

mkdir -p "$WIN_MEDIA_DIR" "$LINUX_MEDIA_DIR" "$HOME/bin"

# Ensure Wine is installed for Windows executables
if ! command -v wine >/dev/null 2>&1; then
    echo "Installing Wine..."
    sudo apt update
    sudo apt install -y wine winetricks
fi


get_latest_release_url() {
    local REPO="$1"
    local PATTERN="$2"  # regex to match asset name

    curl -s "https://api.github.com/repos/$REPO/releases/latest" \
        | jq -r ".assets[] | select(.name | test(\"$PATTERN\")) | .browser_download_url"
}

BOOKLIB_DIR="$HOME/code/tools/windows"
mkdir -p "$BOOKLIB_DIR"

BOOKLIB_URL=$(get_latest_release_url "audiamus/BookLibConnect" "-Setup.exe$")
BOOKLIB_DEST="$BOOKLIB_DIR/BookLibConnect.exe"

if [ ! -f "$BOOKLIB_DEST" ]; then
    echo "Downloading BookLibConnect..."
    curl -L "$BOOKLIB_URL" -o "$BOOKLIB_DEST"
fi

# Wine wrapper
cat > "$HOME/bin/booklibconnect" <<EOF
#!/usr/bin/env bash
WINEPREFIX="\$HOME/.wine" wine "$BOOKLIB_DEST" "\$@"
EOF
chmod +x "$HOME/bin/booklibconnect"

BANDCAMP_DIR="$HOME/code/tools/windows"
mkdir -p "$BANDCAMP_DIR"

BANDCAMP_URL=$(get_latest_release_url "Otiel/BandcampDownloader" ".*Downloader.zip$")
BANDCAMP_DEST="$BANDCAMP_DIR/bandcamp-downloader.zip"
BANDCAMP_EXTRACT="$BANDCAMP_DIR/bandcamp-downloader"

if [ ! -f "$BANDCAMP_DEST" ]; then
    echo "Downloading Bandcamp Downloader..."
    curl -L "$BANDCAMP_URL" -o "$BANDCAMP_DEST"
    mkdir -p "$BANDCAMP_EXTRACT"
    unzip -o "$BANDCAMP_DEST" -d "$BANDCAMP_EXTRACT"
fi

# Wine wrapper (assuming .exe inside zip)
cat > "$HOME/bin/bandcampdownloader" <<EOF
#!/usr/bin/env bash
WINEPREFIX="\$HOME/.wine" wine "$BANDCAMP_EXTRACT/BandcampDownloader.exe" "\$@"
EOF
chmod +x "$HOME/bin/bandcampdownloader"

SPOTDL_DIR="$HOME/code/tools/linux"
mkdir -p "$SPOTDL_DIR"

SPOTDL_URL=$(get_latest_release_url "spotDL/spotify-downloader" ".*-linux$")
SPOTDL_BIN="$SPOTDL_DIR/spotdl"

if [ ! -f "$SPOTDL_BIN" ]; then
    echo "Downloading Spotify Downloader..."
    curl -L "$SPOTDL_URL" -o "$SPOTDL_BIN"
    chmod +x "$SPOTDL_BIN"
fi

ln -sf "$SPOTDL_BIN" "$HOME/bin/spotdl"


MEDIA_OPTIONAL=$(yq e '.media-optional' setup.yaml)

if [ "$MEDIA_OPTIONAL" = "false" ]; then
    exit 0
fi

echo "Installing optional media packages..."

OPTIONAL_APPS=(krita gimp audacity)
for app in "${OPTIONAL_APPS[@]}"; do
    if ! command -v "$app" >/dev/null 2>&1; then
        sudo apt install -y "$app" || echo "Warning: Could not install $app, continuing..."
    fi
done
