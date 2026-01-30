#!/usr/bin/env bash

echo "Gaming module starting..."

STEAM=$(yq e '.["gaming-options"].steam' setup.yaml)
HEROIC=$(yq e '.["gaming-options"].heroic' setup.yaml)
OPENRCT2=$(yq e '.["gaming-options"].openrct2' setup.yaml)
EMULATION=$(yq e '.["gaming-options"].emulation' setup.yaml)

if [ "$STEAM" = "true" ]; then
  echo "Installing Steam..."
  if ! command -v steam >/dev/null 2>&1; then
    sudo apt install -y steam-installer || echo "Steam install failed"
  fi
fi

if [ "$HEROIC" = "true" ]; then
  echo "Installing Heroic Launcher..."
  APPDIR="$HOME/Applications"
  mkdir -p "$APPDIR"
  APPIMAGE="$APPDIR/heroic.AppImage"

  # Get latest release URL
  HEROIC_URL=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest \
     | jq -r '.assets[] | select(.name | test("linux-x86_64.AppImage$")) | .browser_download_url')

  if [ -z "$HEROIC_URL" ]; then
    echo "Could not find linux-x86_64.AppImage for Heroic!"
  else
    # Only download if file doesn't exist
    if [ ! -f "$APPIMAGE" ]; then
      echo "Downloading Heroic..."
      curl -L "$HEROIC_URL" -o "$APPIMAGE"
      chmod +x "$APPIMAGE"
      echo "Heroic installed at $APPIMAGE"
    fi
  fi
fi


if [ "$OPENRCT2" = "true" ]; then
  echo "Installing OpenRCT2 (AppImage)..."
  APPDIR="$HOME/Applications"
  mkdir -p "$APPDIR"
  APPIMAGE="$APPDIR/OpenRCT2.AppImage"
  RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/OpenRCT2/OpenRCT2/releases/latest")
  DOWNLOAD_URL=$(echo "$RELEASE_JSON" \
    | jq -r '.assets[] | select(.name | test("linux-x86_64.AppImage$")) | .browser_download_url')

  if [ -z "$DOWNLOAD_URL" ]; then
    echo "Could not find linux-x86_64.AppImage for OpenRCT2!"
  else
    # Only download if it doesn't exist
    if [ ! -f "$APPIMAGE" ]; then
      echo "Downloading OpenRCT2..."
      curl -L "$DOWNLOAD_URL" -o "$APPIMAGE"
      chmod +x "$APPIMAGE"
      echo "OpenRCT2.AppImage installed to $APPDIR"
    fi
  fi
fi


if [ "$EMULATION" = "true" ]; then
  echo "Installing emulation tools..."
  sudo apt install -y retroarch dosbox || echo "Emulation install failed"
fi

EXTRAS=(gamemode mangohud wine winetricks xpad)
for pkg in "${EXTRAS[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        if ! sudo apt install -y "$pkg"; then
            echo "Could not install $pkg via apt"
        fi
    fi
done
