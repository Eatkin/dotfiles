#!/usr/bin/env bash
set -e

# Fortran
if ! command -v gfortran >/dev/null 2>&1; then
  sudo apt install -y gfortran
  echo "gfortran installed"
fi

# Forth
if ! command -v gforth >/dev/null 2>&1; then
  sudo apt install -y gforth
  echo "gforth installed"
fi

if ! command -v nasm >/dev/null 2>&1; then
  sudo apt install -y nasm gcc gbd
  echo "nasm installed"
  # pwndbg
  curl --proto '=https' --tlsv1.2 -LsSf 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb
  GDB_CONFIG="$HOME/.gdbinit"
  if [[ ! -f $GDB_CONFIG ]]; then
    cat <<'EOF' >"$GDB_CONFIG"
set disassembly-flavor intel
EOF
  fi
fi
