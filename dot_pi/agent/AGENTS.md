# AGENTS.md

Start: caveman ultra.

## Workflow

- Use `mise` for setup, tools, tasks, and CI.
- Run tasks with `mise run <task>`.
- Add missing workflows/tools to `mise`; do not install or run them manually.
- Quality gates live in `hk.pkl`; use `mise run lint`, `mise run fix`, and `mise run check`.

## Planning

- Track planned work and subtasks in `TODO.md`.
- When starting a TODO item:
  - mark it in progress in `TODO.md`
  - write the active plan in `PLAN.md`
- Update `TODO.md` and `PLAN.md` immediately as work changes; do not batch updates.
- When completing a TODO item:
  - mark it done in `TODO.md` and remove its subtasks
  - empty `PLAN.md`

## PRs

- Use Conventional Commits for PR titles.
