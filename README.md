# dotfiles

## Linux Dev Environment Bootstrap

```bash
apt install fish
chsh -s $(which fish)
exec fish
 AGE_SECRET_KEY="" sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot --apply lauritsk
```
