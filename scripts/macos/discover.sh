#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Skipping: discover.sh is macOS-only."
  exit 0
fi

SNAPSHOT_ROOT="${MACOS_DISCOVERY_DIR:-/tmp/macos-defaults-discovery}"

DEFAULT_DOMAINS=(
  NSGlobalDomain
  com.apple.finder
  com.apple.dock
  com.apple.screencapture
  com.apple.trackpad
)

usage() {
  cat <<'EOF'
Usage:
  bash scripts/macos/discover.sh capture <label> [domain...]
  bash scripts/macos/discover.sh diff <before-label> <after-label>
  bash scripts/macos/discover.sh list

Examples:
  bash scripts/macos/discover.sh capture before com.apple.finder
  # Change a setting in System Settings or Finder preferences...
  bash scripts/macos/discover.sh capture after com.apple.finder
  bash scripts/macos/discover.sh diff before after

Notes:
  - Snapshots are stored in /tmp/macos-defaults-discovery by default.
  - Override with MACOS_DISCOVERY_DIR=/path/to/dir.
EOF
}

safe_name() {
  # Convert domain/file labels to predictable file names.
  printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '_'
}

capture_domain() {
  local label="$1"
  local domain="$2"
  local target_dir="${SNAPSHOT_ROOT}/${label}"
  local domain_file
  local tmp_plist

  domain_file="$(safe_name "$domain")"
  tmp_plist="$(mktemp)"

  if defaults export "$domain" "$tmp_plist" >/dev/null 2>&1; then
    if plutil -convert xml1 -o "${target_dir}/${domain_file}.plist" "$tmp_plist" >/dev/null 2>&1; then
      echo "Captured ${domain} -> ${target_dir}/${domain_file}.plist"
    else
      cp "$tmp_plist" "${target_dir}/${domain_file}.plist"
      echo "Captured ${domain} -> ${target_dir}/${domain_file}.plist"
    fi
  else
    if defaults read "$domain" > "${target_dir}/${domain_file}.txt" 2>/dev/null; then
      echo "Captured ${domain} -> ${target_dir}/${domain_file}.txt"
    else
      echo "WARN: could not read domain ${domain}"
    fi
  fi

  rm -f "$tmp_plist"
}

capture() {
  local label="$1"
  shift || true

  mkdir -p "${SNAPSHOT_ROOT}/${label}"

  {
    echo "captured_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "label=${label}"
  } > "${SNAPSHOT_ROOT}/${label}/_meta.txt"

  if [[ $# -eq 0 ]]; then
    for domain in "${DEFAULT_DOMAINS[@]}"; do
      capture_domain "$label" "$domain"
    done
    return
  fi

  for domain in "$@"; do
    capture_domain "$label" "$domain"
  done
}

list_snapshots() {
  mkdir -p "$SNAPSHOT_ROOT"
  ls -1 "$SNAPSHOT_ROOT"
}

diff_snapshots() {
  local before="$1"
  local after="$2"
  local before_dir="${SNAPSHOT_ROOT}/${before}"
  local after_dir="${SNAPSHOT_ROOT}/${after}"
  local files
  local changed=0

  if [[ ! -d "$before_dir" ]]; then
    echo "Missing snapshot: $before_dir" >&2
    exit 1
  fi
  if [[ ! -d "$after_dir" ]]; then
    echo "Missing snapshot: $after_dir" >&2
    exit 1
  fi

  files="$(
    {
      (cd "$before_dir" && find . -type f | sort)
      (cd "$after_dir" && find . -type f | sort)
    } | sort -u
  )"

  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    [[ "$file" == "./_meta.txt" ]] && continue

    if [[ ! -f "${before_dir}/${file}" ]]; then
      echo "ADDED   ${file#./}"
      changed=1
      continue
    fi
    if [[ ! -f "${after_dir}/${file}" ]]; then
      echo "REMOVED ${file#./}"
      changed=1
      continue
    fi

    if ! diff -u "${before_dir}/${file}" "${after_dir}/${file}" >/dev/null; then
      echo
      echo "CHANGED ${file#./}"
      diff -u "${before_dir}/${file}" "${after_dir}/${file}" || true
      changed=1
    fi
  done <<< "$files"

  if [[ $changed -eq 0 ]]; then
    echo "No differences found."
  fi
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    capture)
      [[ $# -lt 2 ]] && { usage; exit 1; }
      shift
      capture "$@"
      ;;
    diff)
      [[ $# -ne 3 ]] && { usage; exit 1; }
      diff_snapshots "$2" "$3"
      ;;
    list)
      list_snapshots
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
