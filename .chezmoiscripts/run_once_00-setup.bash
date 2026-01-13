#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"

exists() {
  command -v "$1" >/dev/null 2>&1
}

echo "🚀 Starting system bootstrap for $OS ($ARCH)..."

if [ "$OS" = "Darwin" ]; then
    echo "🍎 macOS detected."

elif [ "$OS" = "Linux" ]; then
    echo "🐧 Linux detected."

    if [ -f /etc/os-release ]; then
        . /etc/os-release

        if [[ "$ID_LIKE" == "debian" ]]; then
            echo "📦 Installing Debian/Ubuntu dependencies..."
            sudo apt update -y && sudo apt install -y curl git build-essential

        elif [[ "$ID" == "fedora" ]]; then
            echo "📦 Installing Fedora dependencies..."
            sudo dnf update -y && sudo dnf install -y curl git @development-tools

        elif [[ "$ID_LIKE" == "arch" ]]; then
            echo "📦 Installing Arch dependencies..."
            sudo pacman -Syu --noconfirm --needed curl git base-devel
        fi
    else
        echo "⚠️  Warning: Unknown Linux distribution. Skipping system deps."
    fi
fi

if [[ "$OS" == "Darwin" && "$ARCH" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
elif [[ "$OS" == "Linux" ]]; then
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

if ! exists "$BREW_PREFIX/bin/brew"; then
    echo "🍺 Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew already installed."
fi

if [ -f "$HOME/.Brewfile" ]; then
    echo "📦 Running Homebrew Bundle..."
    $BREW_PREFIX/bin/brew bundle --global
else
    echo "⚠️  No Brewfile found in Home directory. Skipping bundle."
fi

FISH_BIN="$BREW_PREFIX/bin/fish"
if [ -x "$FISH_BIN" ]; then
    echo "🐠 Configuring Fish shell..."

    if ! grep -q "$FISH_BIN" /etc/shells; then
        echo "Adding $FISH_BIN to /etc/shells..."
        echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
    fi

    echo "Changing default shell to Fish..."
    sudo chsh -s "$FISH_BIN" "$USER"

else
    echo "⚠️  Fish binary not found at $FISH_BIN. Is it listed in your Brewfile?"
fi

echo "✅ Setup complete!
