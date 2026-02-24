# dotfiles

## macOS Bootstrap

```bash
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lauritsk
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

## Declarative macOS Settings

Registry and workflow are in `docs/macos-settings.md`.

Apply tracked settings:

```bash
bash scripts/macos/apply.sh
```

Verify drift:

```bash
bash scripts/macos/verify.sh
```

Discover new settings to track:

```bash
bash scripts/macos/discover.sh capture before com.apple.finder
# Toggle one setting in UI
bash scripts/macos/discover.sh capture after com.apple.finder
bash scripts/macos/discover.sh diff before after
```

Promote a discovered key into the settings registry:

```bash
bash scripts/macos/promote-setting.sh \
  --id finder.show_path_bar \
  --domain com.apple.finder \
  --key ShowPathbar \
  --type bool \
  --desired true \
  --reload Finder \
  --notes "Show Finder path bar"
```

Normal use with chezmoi:

```bash
chezmoi apply
```
