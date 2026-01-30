#!/usr/bin/env bash

DATA_DIR="$HOME/.data-sources"

if [ ! -d "$DATA_DIR" ]; then
  echo "Creating data sources directory at $DATA_DIR"
  mkdir -p "$DATA_DIR"
fi
echo "Data module initialised"

