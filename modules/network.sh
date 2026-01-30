#!/usr/bin/env bash
set -e

echo "Installing network tools..."

# FileZilla 
if ! command -v filezilla >/dev/null 2>&1; then
  sudo apt install -y filezilla
fi

# OpenSSH server 
if ! dpkg -s openssh-server >/dev/null 2>&1; then
  echo "Installing openssh-server (disabled by default)..."
  sudo apt install -y openssh-server
fi

echo "Network tools installed"

