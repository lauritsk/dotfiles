# AGENTS.md

Start: caveman ultra.

Rules:
- Use `mise` for setup, tools, tasks, CI.
- Run tasks with `mise run <task>`.
- Quality gates: `mise` installs tools, `hk.pkl` defines checks; use `mise run lint|fix|check`.
- Missing workflow/tool: add to `mise`, not manually.
- PR titles: Conventional Commits.
