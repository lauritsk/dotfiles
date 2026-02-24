#!/usr/bin/env bash
set -euo pipefail

DOCS_FILE="docs/macos-settings.md"
ID=""
DOMAIN=""
KEY=""
TYPE=""
DESIRED=""
RELOAD=""
NOTES=""
INFER_DESIRED=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage:
  bash scripts/macos/promote-setting.sh \
    --id <id> \
    --domain <domain> \
    --key <key> \
    --type <bool|int|string|float> \
    [--desired <value>] \
    [--infer-desired] \
    [--reload <target>] \
    [--notes <text>] \
    [--docs <path>] \
    [--dry-run]

Examples:
  bash scripts/macos/promote-setting.sh \
    --id finder.show_path_bar \
    --domain com.apple.finder \
    --key ShowPathbar \
    --type bool \
    --desired true \
    --reload Finder \
    --notes "Show Finder path bar"

  bash scripts/macos/promote-setting.sh \
    --id dock.tilesize \
    --domain com.apple.dock \
    --key tilesize \
    --type int \
    --infer-desired \
    --reload Dock
EOF
}

escape_cell() {
  printf '%s' "$1" | sed 's/|/\\|/g'
}

normalize_bool() {
  local v
  v="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$v" in
    1|true|yes|on) echo "true" ;;
    0|false|no|off) echo "false" ;;
    *)
      echo "Invalid boolean value: $1" >&2
      exit 1
      ;;
  esac
}

infer_desired_value() {
  if ! DESIRED="$(defaults read "$DOMAIN" "$KEY" 2>/dev/null)"; then
    echo "Could not infer value from defaults read $DOMAIN $KEY" >&2
    exit 1
  fi
}

build_apply_cmd() {
  case "$TYPE" in
    bool)
      local bool_value
      bool_value="$(normalize_bool "$DESIRED")"
      echo "defaults write $DOMAIN $KEY -bool $bool_value"
      ;;
    int)
      echo "defaults write $DOMAIN $KEY -int $DESIRED"
      ;;
    float)
      echo "defaults write $DOMAIN $KEY -float $DESIRED"
      ;;
    string)
      echo "defaults write $DOMAIN $KEY -string \"$DESIRED\""
      ;;
    *)
      echo "Unsupported type: $TYPE" >&2
      exit 1
      ;;
  esac
}

build_verify_expected() {
  case "$TYPE" in
    bool)
      if [[ "$(normalize_bool "$DESIRED")" == "true" ]]; then
        echo "1"
      else
        echo "0"
      fi
      ;;
    *)
      echo "$DESIRED"
      ;;
  esac
}

append_row() {
  local apply_cmd="$1"
  local verify_expected="$2"
  local verify_cmd="defaults read $DOMAIN $KEY"
  local row

  row="| $(escape_cell "$ID") | $(escape_cell "$DOMAIN") | $(escape_cell "$KEY") | $(escape_cell "$TYPE") | $(escape_cell "$DESIRED") | \`$(escape_cell "$apply_cmd")\` | \`$(escape_cell "$verify_cmd")\` => \`$(escape_cell "$verify_expected")\` | $(escape_cell "$RELOAD") | $(escape_cell "$NOTES") |"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "Dry run: would append row to $DOCS_FILE"
    echo "$row"
    return
  fi

  printf '\n%s\n' "$row" >> "$DOCS_FILE"
  echo "Appended row to $DOCS_FILE"
}

print_snippets() {
  local apply_cmd="$1"
  local verify_expected="$2"

  cat <<EOF

Add this line to scripts/macos/apply.sh:
  $apply_cmd

Add this line to scripts/macos/verify.sh:
  assert_default $DOMAIN $KEY $verify_expected $ID
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) ID="${2:-}"; shift 2 ;;
      --domain) DOMAIN="${2:-}"; shift 2 ;;
      --key) KEY="${2:-}"; shift 2 ;;
      --type) TYPE="${2:-}"; shift 2 ;;
      --desired) DESIRED="${2:-}"; shift 2 ;;
      --reload) RELOAD="${2:-}"; shift 2 ;;
      --notes) NOTES="${2:-}"; shift 2 ;;
      --docs) DOCS_FILE="${2:-}"; shift 2 ;;
      --infer-desired) INFER_DESIRED=1; shift ;;
      --dry-run) DRY_RUN=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *)
        echo "Unknown argument: $1" >&2
        usage
        exit 1
        ;;
    esac
  done
}

validate() {
  TYPE="$(printf '%s' "$TYPE" | tr '[:upper:]' '[:lower:]')"

  [[ -z "$ID" ]] && { echo "--id is required" >&2; exit 1; }
  [[ -z "$DOMAIN" ]] && { echo "--domain is required" >&2; exit 1; }
  [[ -z "$KEY" ]] && { echo "--key is required" >&2; exit 1; }
  [[ -z "$TYPE" ]] && { echo "--type is required" >&2; exit 1; }

  if [[ $INFER_DESIRED -eq 1 ]]; then
    infer_desired_value
  fi
  [[ -z "$DESIRED" ]] && { echo "--desired is required unless --infer-desired is used" >&2; exit 1; }

  if [[ ! -f "$DOCS_FILE" ]]; then
    echo "Docs file not found: $DOCS_FILE" >&2
    exit 1
  fi
}

main() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Warning: running outside macOS. --infer-desired may fail." >&2
  fi

  parse_args "$@"
  validate

  local apply_cmd
  local verify_expected
  apply_cmd="$(build_apply_cmd)"
  verify_expected="$(build_verify_expected)"

  append_row "$apply_cmd" "$verify_expected"
  print_snippets "$apply_cmd" "$verify_expected"
}

main "$@"
