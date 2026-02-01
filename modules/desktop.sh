#!/usr/bin/env bash

set -e

echo "Setting up desktop module..."

# Ensure systemd user dir exists
mkdir -p ~/.config/systemd/user

# List of startup commands
STARTUP_LIST="$HOME/.cosmic_startup_list"
if [ ! -f "$STARTUP_LIST" ]; then
  echo "Creating startup list in $STARTUP_LIST"
  echo "# format: <directory> <command>" > "$STARTUP_LIST"
  echo "$HOME ls" >> "$STARTUP_LIST"
fi

# Startup script
STARTUP_SCRIPT="$HOME/.cosmic_startup_script.sh"
if [ ! -f "$STARTUP_SCRIPT" ]; then
  echo "Creating startup script at $STARTUP_SCRIPT"
  cat <<EOF > "$STARTUP_SCRIPT"
while read dir cmd; do
  # Bypass - cosmic-term does not allow --tab like gnome terminal (yet)
  # Skip empty lines or lines starting with #
  [[ -z "$dir" || "$dir" =~ ^# ]] && continue
  if [ -n "$cmd" ]; then
    cosmic-term --tab -d "$dir" -e "$cmd"
  else
    cosmic-term --tab -d "$dir"
  fi
done
# Literally just open Terminal
cosmic-term < "$STARTUP_LIST"
EOF

  chmod +x "$STARTUP_SCRIPT"
fi

# Systemctl service
STARTUP_SERVICE="$HOME/.config/systemd/user/cosmic-startup.service"
if [ ! -f "$STARTUP_SERVICE" ]; then
  echo "Creating startup service at $STARTUP_SERVICE"
  cat <<EOF > "$STARTUP_SERVICE"
[Unit]
Description=Start Cosmic Terminal on login
After=graphical.target

[Service]
Type=simple
ExecStart=$STARTUP_SCRIPT
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

  # Enable the service
  echo "Enabling the startup service..."
  systemctl --user daemon-reload
  systemctl --user enable cosmic-startup.service
  systemctl --user start cosmic-startup.service
fi

