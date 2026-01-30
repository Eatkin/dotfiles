#!/usr/bin/env bash
set -e

echo "Installing LaTeX toolchain..."

LATEX_PACKAGES=(
  texlive
  texlive-latex-extra
  texlive-fonts-recommended
  texlive-fonts-extra
  texlive-science
  texlive-xetex
  texlive-luatex
  texlive-bibtex-extra
  texlive-pictures
  latexmk
  biber
)

for pkg in "${LATEX_PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    sudo apt install -y "$pkg" || echo "Failed to collect package $pkg"
  fi
done

echo "LaTeX core installed"

