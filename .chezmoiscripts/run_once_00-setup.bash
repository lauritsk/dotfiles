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
        
        if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
            echo "📦 Installing Debian/Ubuntu dependencies..."
            sudo apt update -y
            sudo apt install -y curl git build-essential
            
        elif [[ "$ID" == "fedora" ]]; then
            echo "📦 Installing Fedora dependencies..."
            sudo dnf update -y
            sudo dnf install -y curl git 
            sudo dnf group install development-tools
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

echo "🔧 Initializing Homebrew environment..."
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

echo "✅ Setup complete! Brew version: $(brew --version | head -n1)"
