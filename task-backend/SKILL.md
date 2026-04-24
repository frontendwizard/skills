---
name: task-backend
description: Resolve the project's task-tracking backend and expose a uniform verb vocabulary (create_epic, create_task, create_subtask, comment, update, get, list_open) for PRDs, plans, and tickets. Use when a skill needs to create or update tracked work items and must stay backend-agnostic across GitHub Issues, Backlog.md, dex, or local Markdown. Other skills load this one before calling any task verb.
---

# Task Backend

Uniform abstraction over task trackers. Skills call verbs here instead of hardcoding `gh issue create`, `backlog task create`, `dex add`, etc.

## Artifact model

| Verb | Used for | Mapping |
| --- | --- | --- |
| `create_epic` | PRDs | Top-level long-lived container |
| `create_task` | Single plan, or one phase of a multi-phase plan | Standalone or child of an epic |
| `create_subtask` | A chunky step inside a big phase | Child of a task |

Multi-phase plans → one `create_epic` + one `create_task` per phase with `parent_epic` set. Big phases → `create_subtask` under that phase's task.

## Resolve the backend

1. Explicit instruction in the current turn wins.
2. `.skills/config.local.toml` (gitignored per-user override).
3. `.skills/config.toml` (committed project default).
4. If none exist, ask the user once which backend to use and offer to write `.skills/config.toml`.

Run `task-backend/scripts/resolve-backend.sh` to get the resolved backend name deterministically. It prints one of: `github`, `backlog-md`, `dex`, `local`.

Before creating any artifact, state which backend was resolved and why.

## Config schema (`.skills/config.toml`)

```toml
[tasks]
backend = "backlog-md"  # "github" | "backlog-md" | "dex" | "local"

[tasks.github]
repo = ""               # optional; gh auto-detects if empty

[tasks.backlog-md]
root = ".backlog"

[tasks.dex]
# dex auto-detects project; no keys required

[tasks.local]
plans_dir = "plans"
```

`.skills/config.local.toml` uses the same shape and overrides field-by-field.

## Verb vocabulary

All verbs return a backend-specific identifier (issue number, task id, file path) and a URL or path suitable for printing back to the user.

- `create_epic(title, body) -> id`
- `create_task(title, body, parent_epic?) -> id`
- `create_subtask(title, body, parent_task) -> id`
- `get(id) -> {title, body, status, parent, url}`
- `list_open(filter?) -> [id, ...]`
- `update(id, fields)` — status, labels, parent, body
- `comment(id, body)`

## Executing a verb

1. Resolve the backend (above).
2. Read the matching recipe file and run the commands it lists for that verb, substituting fields from the call:
   - `github` → [backends/github.md](backends/github.md)
   - `backlog-md` → [backends/backlog-md.md](backends/backlog-md.md)
   - `dex` → [backends/dex.md](backends/dex.md)
   - `local` → [backends/local.md](backends/local.md)
3. Print the returned URL or file path to the user.

## Rules

- Never bypass the resolver. If a skill has a GitHub-only step (e.g. label state machines), it must declare itself GitHub-only in its own description, not quietly assume.
- Keep artifact bodies identical across backends. Only the transport changes.
- Do not mix backends in one session unless the user explicitly asks.
- When a backend cannot express a relationship (e.g. `local` has no real parent link), record the parent as a reference line at the top of the artifact body.
