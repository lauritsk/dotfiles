# dotfiles

## macOS Bootstrap

```bash
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot --apply lauritsk
command -v fish | sudo tee -a /etc/shells > /dev/null
chsh -s "$(command -v fish)"
```

## YubiKey Bootstrap

```bash
cd ~/.ssh
ssh-keygen -K
mv id_ed25519_sk_rk id_ed25519
mv id_ed25519_sk_rk.pub id_ed25519.pub
```

## Linux Dev Environment Bootstrap

```bash
 AGE_SECRET_KEY="" sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lauritsk
```
