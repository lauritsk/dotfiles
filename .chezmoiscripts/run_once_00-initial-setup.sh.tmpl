#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"

echo "🚀 Starting system bootstrap for $OS ($ARCH)..."

if [[ "$OS" = "Darwin" ]]; then
    echo "🍎 macOS detected."

elif [[ "$OS" = "Linux" ]]; then
    echo "🐧 Linux detected."

    if [[ -f /etc/os-release ]]; then
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

if ! command -v "$BREW_PREFIX/bin/brew"; then
    echo "🍺 Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew already installed."
fi

echo "🌍 Activating Homebrew environment..."
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

if [[ -f "$HOME/.config/homebrew/Brewfile" ]]; then
    echo "📦 Running Homebrew Bundle..."
    brew bundle --global
else
    echo "⚠️  No Brewfile found. Skipping bundle."
fi

if [[ -f "$HOME/.config/mise/config.toml" ]]; then
    echo "📦  Installing Mise packages..."
    mise install
else
    echo "⚠️  No mise config file found. Skipping mise install."
fi

if FISH_PATH="$(command -v fish)"; then
    echo "🐠 Configuring Fish shell..."
    echo "   Found at: $FISH_PATH"

    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "   Adding to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    if [[ "$SHELL" != "$FISH_PATH" ]]; then
        echo "   Changing default shell to Fish..."
        sudo chsh -s "$FISH_PATH" "$USER"
    else
        echo "   Fish is already the default shell."
    fi
else
    echo "⚠️  Fish command not found in PATH. Is it listed in your Brewfile?"
fi

echo "✅ Setup complete!"
