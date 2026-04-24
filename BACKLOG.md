# Backlog.md setup for this repo

This repo dogfoods the `backlog-md` task backend.

Backend selection lives in `.skills/config.toml`. See [skills/task-backend/SKILL.md](skills/task-backend/SKILL.md) for the schema, verb vocabulary, and per-backend recipes.

## Local-first shape

- `.backlog/` at the repo root holds all task state
- `.backlog/` is gitignored
- execution happens in pi sessions or your own loop, not inside Backlog.md itself

That keeps task state out of repo history while giving skills a stable path to discover.

## What is committed vs private

**Committed:**

- `.skills/config.toml` — backend selection (`backend = "backlog-md"`)
- `plans/*.md` — durable parent plans for multi-phase work when you want them in history

**Private / local-only:**

- `.backlog/` — Backlog.md workspace and all task state
- `.skills/config.local.toml` — optional per-user backend override

## One-time setup

```bash
backlog init
mkdir -p .backlog/{tasks,docs,decisions,drafts,archive,completed,milestones}
git check-ignore -v .backlog    # confirm it is ignored
```

If stronger physical separation is wanted later, `.backlog` can be replaced with a symlink to a path outside the repo. Optional, not the default.

## End-to-end example

For any feature:

1. `to-prd` interviews the user and calls `create_epic(...)` → Backlog.md task with `epic` label, optionally with a companion PRD doc under `.backlog/docs/`
2. `to-tasks` (or `request-refactor-plan` for refactors) breaks the epic into phase tasks via `create_task(..., parent_epic=<id>)`
3. A chunky phase can add `create_subtask(..., parent_task=<id>)` steps
4. A pi session or `do-work/scripts/afk-do-work-loop.sh` picks the highest-priority unblocked task
5. `do-work` implements exactly one task and creates the commit
6. Status updates happen locally in `.backlog/`; code history happens in git

## Minimal execution loop

No extra orchestration required. Manual loop:

1. Read next unblocked task from `.backlog/tasks/`
2. Read relevant plan and recent commits
3. Ask pi to do exactly that one task
4. Validate and commit
5. Mark the task done in Backlog.md

The checked-in tmux loop at `do-work/scripts/afk-do-work-loop.sh` automates steps 1–4 while keeping all task-picking and completion logic inside `/do-work`.
