# Dots

1. Ensure age key is set in ~/key.txt

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot $GITHUB_USERNAME
brew bundle --global
command -v fish | sudo tee -a /etc/shells
sudo chsh -s "$(command -v fish)" $USER
```
