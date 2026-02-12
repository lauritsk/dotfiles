# dotfiles

## macOS bootstrap

```bash
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lauritsk
command -v fish | sudo tee -a /etc/shells > /dev/null
chsh -s "$(command -v fish)"
```
