# AGENTS.md

Start: caveman ultra.

## Workflow

- Use `mise` for setup, tools, tasks, and CI.
- Run tasks with `mise run <task>`.
- Add (repeated) missing workflows/tools to `mise`; do not install or run them manually.
- `mise` tasks: repeated, durable, rarely changed; not one-offs.
- Quality gates live in `hk.pkl`; use `mise run lint`, `mise run fix`, and `mise run check`.

## Planning

- Git forge (github, gitlab, forgejo) issues are the source of truth for task tracking.
- Record subtasks, status updates, decisions, and scope changes.
- Keep issue status current as work starts, changes, and completes.

## Git

- When merging branches, always squash. Do not create merge commits. Do not fast-forward.

## PRs

- Use Conventional Commits for PR titles.
