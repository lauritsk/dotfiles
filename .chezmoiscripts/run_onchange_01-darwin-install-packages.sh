#!/bin/zsh
set -euo pipefail

echo "Installing Homebrew packages from Brewfile..."

brew bundle --file="{{ .chezmoi.homeDir }}/.Brewfile"

echo "Homebrew packages installed successfully."
