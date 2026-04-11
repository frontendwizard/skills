# Planning Backends

This file is the source of truth for portable planning and work-tracking conventions in this repo.

## Repo default

This repo defaults to the `backlog` backend.

- Checked-in project default: `.pi/planning.json`
- Optional local private override: `.pi/planning.local.json`
- Recommended backlog root from the repo: `.backlog`

The repo should use Backlog.md as a private GitHub-issues replacement. Execution still happens in pi sessions or your own scripts.

## Supported backends

### `github`

Use GitHub issues for remote planning and ticket tracking.

### `backlog`

Use Backlog.md as a local-first issue replacement. Treat it as a planning and ticket store, not as an execution runtime.

### `local`

Use minimal local Markdown planning. For multi-slice work, keep a plan file in `plans/`. Commits act as the tickets.

## Backend selection precedence

When a portable planning skill needs a backend, resolve it in this order:

1. Explicit user instruction for the current run
2. Local private override in `.pi/planning.local.json`
3. Checked-in project default in `.pi/planning.json`

If no explicit instruction or override exists, this repo should behave as `backlog`.

## Artifact model

### PRD

A PRD defines feature requirements and user stories. Use PRDs for feature work.

### Plan

A plan breaks implementation into one or more vertical slices. For multi-slice work, the plan is the parent artifact.

### Ticket or task

A ticket or task is the executable unit of work for one slice.

### Execution

Execution is how work actually gets done: a human-in-the-loop pi session, the `do-work` skill, or a custom local loop/script. Execution is outside the planning backend abstraction.

## Rules portable planning skills should follow

- Support exactly three backends in v1: `github`, `backlog`, and `local`
- Keep planning/work tracking separate from execution
- Use PRDs for feature work, not for every refactor, bug fix, or maintenance change
- For single-slice work, create one executable ticket/task in the selected backend
- For multi-slice work, create a parent plan artifact plus child tickets/tasks in the selected backend
- In `backlog` mode, prefer Backlog.md-native artifacts and relationships
- In `local` mode, avoid noisy child ticket files
- Keep GitHub-native governance and maintainer workflows explicitly GitHub-specific

## Recommended `.backlog` setup

The supported local-first setup is a hidden repo path inside the repo root that stays gitignored.

Example:

```bash
mkdir -p .backlog
```

For the repo-specific bootstrap checklist and a concrete example of how this repo goes from PRD to plan to Backlog.md tasks, see `BACKLOG.md`.

Why this is the recommended shape:

- `.backlog` is easy for tools and skills to discover from the repo root
- `.backlog/` stays gitignored to avoid commit noise
- setup stays simple and does not require symlink management

## Config examples

Checked-in project default in `.pi/planning.json`:

```json
{
  "version": 1,
  "defaultBackend": "backlog",
  "backlogRoot": ".backlog"
}
```

Optional local private override in `.pi/planning.local.json`:

```json
{
  "defaultBackend": "local"
}
```
