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

