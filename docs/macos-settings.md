# macOS Settings Registry

This file tracks settings that are intended to be declarative.

Workflow:
1. Add row for setting.
2. Add `defaults write` command to `scripts/macos/apply.sh`.
3. Add assertion to `scripts/macos/verify.sh`.
4. Run `chezmoi apply` and `bash scripts/macos/verify.sh`.

Discovery loop:
1. Capture baseline for one or more domains.
2. Change exactly one UI setting in System Settings/Finder/Dock.
3. Capture after-state.
4. Diff snapshots and extract the changed key(s).

```bash
bash scripts/macos/discover.sh capture before com.apple.finder
# Toggle one UI setting
bash scripts/macos/discover.sh capture after com.apple.finder
bash scripts/macos/discover.sh diff before after
```

You can omit domains to use defaults (`NSGlobalDomain`, Finder, Dock, Screenshot, Trackpad):

```bash
bash scripts/macos/discover.sh capture before
bash scripts/macos/discover.sh capture after
bash scripts/macos/discover.sh diff before after
```

Promote a discovered setting into the registry:

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

This appends a prefilled table row and prints copy/paste snippets for:
- `scripts/macos/apply.sh`
- `scripts/macos/verify.sh`

| id | domain | key | type | desired | apply_cmd | verify_cmd | reload | notes |
|---|---|---|---|---|---|---|---|---|
| finder.show_extensions | NSGlobalDomain | AppleShowAllExtensions | bool | true | `defaults write NSGlobalDomain AppleShowAllExtensions -bool true` | `defaults read NSGlobalDomain AppleShowAllExtensions` => `1` | Finder | Show all filename extensions |
| finder.show_hidden_files | com.apple.finder | AppleShowAllFiles | bool | true | `defaults write com.apple.finder AppleShowAllFiles -bool true` | `defaults read com.apple.finder AppleShowAllFiles` => `1` | Finder | Show hidden files |
| finder.show_status_bar | com.apple.finder | ShowStatusBar | bool | true | `defaults write com.apple.finder ShowStatusBar -bool true` | `defaults read com.apple.finder ShowStatusBar` => `1` | Finder | Show Finder status bar |
| dock.autohide | com.apple.dock | autohide | bool | true | `defaults write com.apple.dock autohide -bool true` | `defaults read com.apple.dock autohide` => `1` | Dock | Auto-hide dock |
| dock.show_recents | com.apple.dock | show-recents | bool | false | `defaults write com.apple.dock show-recents -bool false` | `defaults read com.apple.dock show-recents` => `0` | Dock | Disable recent apps in dock |
| global.initial_key_repeat | NSGlobalDomain | InitialKeyRepeat | int | 15 | `defaults write NSGlobalDomain InitialKeyRepeat -int 15` | `defaults read NSGlobalDomain InitialKeyRepeat` => `15` | Logout/login may be required | Delay before key repeat starts |
| global.key_repeat | NSGlobalDomain | KeyRepeat | int | 2 | `defaults write NSGlobalDomain KeyRepeat -int 2` | `defaults read NSGlobalDomain KeyRepeat` => `2` | Logout/login may be required | Key repeat speed |
| global.press_and_hold | NSGlobalDomain | ApplePressAndHoldEnabled | bool | false | `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false` | `defaults read NSGlobalDomain ApplePressAndHoldEnabled` => `0` | Restart app | Disable accent popup on key hold |
