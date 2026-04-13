# dotfiles

Portable personal dotfiles powered by `chezmoi` and `mise`.

![chezmoi](https://img.shields.io/badge/chezmoi-managed-4b8bbe?style=flat-square)
![mise](https://img.shields.io/badge/mise-pinned%20tools-8b5cf6?style=flat-square)
![macOS](https://img.shields.io/badge/macOS-supported-111827?style=flat-square)
![Linux](https://img.shields.io/badge/Linux-supported-065f46?style=flat-square)

[Overview](#overview) • [What's Included](#whats-included) • [Getting Started](#getting-started) • [Workflow](#workflow) • [Repository Layout](#repository-layout)

This repository manages a terminal-first development environment with a small, reproducible setup flow. It uses [chezmoi](https://www.chezmoi.io/) to manage dotfiles and templates, and [mise](https://mise.jdx.dev/) to pin tools, tasks, and environment defaults across machines.

## Overview

The goal is a consistent workstation setup with as little manual machine-by-machine tweaking as possible.

Key characteristics:

- `chezmoi` templates for macOS and Linux differences
- `mise` for pinned CLI tools and bootstrap tasks
- opinionated shell, terminal, editor, and Git defaults
- private config support for machine-specific and sensitive files
- a lightweight install flow driven from the repository root

> [!IMPORTANT]
> This repo contains private templates such as SSH and shell configuration. Review them before applying on a new machine, especially if you plan to reuse this setup outside the original environment.

## What's Included

The current setup manages configuration for:

| Area | Tools |
| --- | --- |
| Shell | `fish`, `starship`, `atuin`, `zoxide` |
| Terminal and sessions | `ghostty`, `tmux` |
| Editor and navigation | `helix`, `yazi` |
| Git workflow | `git`, `delta`, `lazygit`, `gh`, `gitsign` |
| Container tooling | `lazydocker` |
| AI and CLI workflow | `opencode`, `fnox`, `usage` |
| Core management | `chezmoi`, `mise` |

Notable conventions in the repo:

- `mise` pins tool versions and exposes setup/check tasks
- shell aliases are defined centrally in `dot_config/mise/config.toml`
- OS-specific behavior is handled in templates for `darwin` and `linux`
- Git defaults are optimized for signed commits, rebasing, delta paging, and GitHub CLI credentials

## Getting Started

### Prerequisites

Install these first:

- `mise`
- `fish`
- `chezmoi` if you want to run it directly outside the provided tasks

On macOS, the repo also includes a `Brewfile` source file (`private_dot_Brewfile`) for machine bootstrap.

### Bootstrap

From the repository root:

```bash
./install
```

The install script runs the repository bootstrap in this order:

```bash
mise trust --all
mise run --raw setup
mise install --raw
```

The `setup` task applies the dotfiles with:

```bash
chezmoi init --apply --source='{{ config_root }}'
```

> [!TIP]
> After the first bootstrap, the usual maintenance loop is just `chezmoi apply` for config changes and `mise install` when tool versions change.

## Workflow

Common commands:

```bash
# Apply the current source state
chezmoi apply

# Reinstall or update pinned tools
mise install

# Run repository checks
mise run check

# Scan the repo for secrets
mise run secrets
```

The repo also includes an editable `chezmoi` config template in `.chezmoi.toml.tmpl` with automatic apply behavior and Git integration enabled.

## Repository Layout

```text
.
├── .chezmoi.toml.tmpl
├── .chezmoiignore
├── install
├── mise.toml
├── dot_config/
├── dot_tmux.conf.tmpl
├── private_dot_Brewfile
└── private_dot_ssh/
```

Layout notes:

- `dot_config/` contains managed files that map into `~/.config/`
- `private_*` paths are for files that should be treated as private by `chezmoi`
- `*.tmpl` files are rendered templates, often with OS-specific logic
- `.chezmoiignore` excludes repository-only bootstrap files such as `install` and `mise.toml` from being applied into `$HOME`

## Platform Notes

This setup is explicitly designed for:

- `macos-arm64`
- `linux-x64`
- `linux-arm64`

There is no Windows-specific configuration in the repository today.

Platform-specific behavior already included:

- Homebrew vs Linuxbrew paths in Fish
- `pbcopy` on macOS and `xclip` on Linux for tmux clipboard support
- OrbStack integration on macOS for shell and SSH config

## Customization

If you want to adapt this repository for your own machines, the main files to review first are:

- `mise.toml`
- `dot_config/mise/config.toml`
- `.chezmoi.toml.tmpl`
- `dot_config/private_fish/config.fish.tmpl`
- `dot_config/git/config.tmpl`
- `private_dot_ssh/private_config.tmpl`

That gives you the toolchain, bootstrap flow, shell behavior, Git defaults, and private SSH setup in one pass.
