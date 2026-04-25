# AGENTS.md

Start: caveman ultra.

Rules:
- Use `mise` for setup, tools, tasks, CI.
- Run tasks with `mise run <task>`.
- Quality gates: `mise` installs tools, `hk.pkl` defines checks; use `mise run lint|fix|check`.
- Missing workflow/tool: add to `mise`, not manually.
- Planned work: write to `TODO.md`.
- Picked TODO item: mark in progress in `TODO.md`; write plan to `PLAN.md`.
- TODO/PLAN updates: do immediately, in real time; do not batch later.
- Completed TODO item: mark done in `TODO.md`; empty `PLAN.md`.
- PR titles: Conventional Commits.
