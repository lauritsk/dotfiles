# dotfiles

## macOS bootstrap

```bash
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lauritsk
command -v fish | sudo tee -a /etc/shells > /dev/null
chsh -s "$(command -v fish)"
```

## YubiKey bootstrap

```bash
cd ~/.ssh
ssh-keygen -K
mv id_ed25519_sk_rk id_ed25519
mv id_ed25519_sk_rk.pub id_ed25519.pub
```
