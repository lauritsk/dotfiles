# AGENTS.md

Start: caveman ultra.

Rules:
- Use `mise` for all tools, setup, tasks, CI, git hooks.
- Prefer `mise run <task>`; else `mise exec <tool> -- <tool> ...`.
- Assume only `mise` installed.
- Do not install tools manually.
- Local and CI must use same `mise` tasks.
- Format and run required checks via `mise` before commit/PR.
- Missing workflow/tool: add to `mise`; do not bypass `mise`, `cog`, hooks, or checks.
- Never use `git commit`; use `mise exec cocogitto -- cog commit <type> <message> [scope]`.
- Use `-B` for breaking changes.
- Releases: `mise exec cocogitto -- cog bump --auto && git push && git push --tags`.
- PR titles must follow Conventional Commits.
