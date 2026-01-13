# Dots

1. Install [Homebrew](https://brew.sh/)

```bash
sudo apt install git build-essential gcc -y
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

2. Ensure age key is set in ~/key.txt

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot $GITHUB_USERNAME
brew bundle
command -v fish | sudo tee -a /etc/shells
sudo chsh -s "$(command -v fish)" $USER
```

## Notes

On linux (Ubuntu at least) install git and maybe build-essential first.
Brew bundle needs to happen automatically or manually described in this file.
