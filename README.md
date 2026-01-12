# dots
personal dotfiles

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot $GITHUB_USERNAME
command -v fish | sudo tee -a /etc/shells
chsh -s "$(command -v fish)"
```
