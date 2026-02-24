#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Skipping: verify.sh is macOS-only."
  exit 0
fi

failures=0

assert_default() {
  local domain="$1"
  local key="$2"
  local expected="$3"
  local id="$4"
  local current

  if ! current="$(defaults read "$domain" "$key" 2>/dev/null)"; then
    echo "FAIL  $id: key missing ($domain $key)"
    failures=$((failures + 1))
    return
  fi

  if [[ "$current" != "$expected" ]]; then
    echo "FAIL  $id: expected=$expected current=$current"
    failures=$((failures + 1))
    return
  fi

  echo "PASS  $id"
}

assert_default NSGlobalDomain AppleShowAllExtensions 1 finder.show_extensions
assert_default com.apple.finder AppleShowAllFiles 1 finder.show_hidden_files
assert_default com.apple.finder ShowStatusBar 1 finder.show_status_bar
assert_default com.apple.dock autohide 1 dock.autohide
assert_default com.apple.dock show-recents 0 dock.show_recents
assert_default NSGlobalDomain InitialKeyRepeat 15 global.initial_key_repeat
assert_default NSGlobalDomain KeyRepeat 2 global.key_repeat
assert_default NSGlobalDomain ApplePressAndHoldEnabled 0 global.press_and_hold

if [[ $failures -ne 0 ]]; then
  echo
  echo "Verification failed: $failures setting(s) drifted."
  exit 1
fi

echo
echo "Verification passed: all tracked settings match desired state."
