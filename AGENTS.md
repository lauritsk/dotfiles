# Repository Guidelines

## Project Structure & Module Organization
This repository is a `chezmoi` source directory for dotfiles and bootstrap automation.

- `dot_*` files map to top-level dotfiles in `$HOME` (example: `dot_Brewfile` -> `~/.Brewfile`).
- `private_dot_config/` maps to `~/.config/*` app configs (`git`, `helix`, `mise`, `fish`, `gh`, etc.).
- `private_dot_ssh/` manages SSH material and templates under `~/.ssh`.
- `.chezmoiscripts/` holds lifecycle scripts (`run_onchange_before_*`, `run_onchange_after_*`) for setup and package sync.
- `*.tmpl` files are Go templates; `encrypted_*.age` and `key.txt.age` are encrypted secrets.

## Build, Test, and Development Commands
There is no compile step; validation is done through `chezmoi` commands.

- `chezmoi diff`: preview what will change in the target home directory.
- `chezmoi apply --dry-run --verbose`: validate rendering and apply behavior without writing files.
- `chezmoi apply`: apply the current source state.
- `chezmoi execute-template < .chezmoiscripts/run_onchange_before_10-initial-setup.sh.tmpl`: render a template for inspection.
- `chezmoi doctor`: check local `chezmoi` health and configuration.

## Coding Style & Naming Conventions
- Use Bash for automation scripts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use 4-space indentation in shell blocks and keep commands explicit and portable.
- Follow `chezmoi` naming patterns consistently: `dot_` for non-sensitive files, `private_` for restricted files, `encrypted_` for age-encrypted files, and `.tmpl` for templated output.
- Keep filenames lowercase and descriptive, using hyphens in script names.

## Testing Guidelines
- No dedicated unit-test framework is defined in this repo.
- Before opening a PR, run `chezmoi diff` and `chezmoi apply --dry-run --verbose`.
- For `.tmpl` script changes, render templates and inspect both OS branches (`darwin` and `linux`) when applicable.
- Never commit decrypted secret material; commit only encrypted `*.age` files.

## Commit & Pull Request Guidelines
- Match current history style: short, imperative commit subjects (example: `Update .Brewfile`, `Fix arch detection in initial setup script`).
- Keep each commit focused to one logical change.
- PRs should include a short purpose statement, touched paths, tested OS (`darwin`, `linux`, or both), and sanitized `chezmoi diff` or dry-run evidence.
- Add a secret-handling note whenever touching key-related or `encrypted_*.age` files.
