# dotfiles

## Linux Dev Environment Bootstrap

```bash
 export AGE_SECRET_KEY=""
AGE_SECRET_KEY="${AGE_SECRET_KEY}" sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot --apply git@github.com:lauritsk/dotfiles.git
```
