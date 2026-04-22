#!/usr/bin/env bash
set -euo pipefail

run() {
  local repo="$1"
  local skill="$2"
  echo ">>> Installing ${skill} from ${repo}"
  npx skills add "$repo" --skill "$skill" --global --yes
  echo
}

run "anthropics/knowledge-work-plugins" "accessibility-review"
run "vercel-labs/agent-browser" "agent-browser"
run "juliusbrussee/caveman" "caveman"
run "github/awesome-copilot" "create-readme"
run "github/awesome-copilot" "documentation-writer"
run "github/awesome-copilot" "multi-stage-dockerfile"
run "github/awesome-copilot" "refactor"
run "github/awesome-copilot" "sql-code-review"
run "github/awesome-copilot" "sql-optimization"
run "github/awesome-copilot" "web-design-reviewer"
run "madsnorgaard/agent-resources" "drupal-expert"
run "madsnorgaard/agent-resources" "drupal-security"
run "getsentry/skills" "find-bugs"
run "openai/skills" "frontend-skill"
run "cloudflare/skills" "sandbox-sdk"

echo ">>> Done. Installed global skills:"
npx skills ls -g --json
