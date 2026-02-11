# dotfiles

## macOS bootstrap

```bash
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lauritsk
```

## daily updates

```bash
chezmoi diff
chezmoi apply
```

## devcontainer template

After apply, the template is available at:

```bash
~/.config/devcontainer/templates/dhi-hardened/.devcontainer
```

Copy it into a repo, set `.env`, and reopen in container.
