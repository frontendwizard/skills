---
name: to-tasks
description: Break a PRD (epic) into independently-grabbable tasks using tracer-bullet vertical slices, filed through the project's configured task backend. Use when a PRD already exists as an epic and the user wants direct PRD-to-tasks fan-out. Works with github, backlog-md, dex, or local per `.skills/config.toml`.
---

# To Tasks

Break a PRD into tracer-bullet tasks. The PRD must already exist as an **epic** in the task backend; this skill creates child **tasks** under it.

Before filing anything, load `task-backend/SKILL.md`, resolve the backend, and use its verbs (`create_task`, optionally `create_subtask`). Do not hardcode `gh`, `backlog`, or `dex` commands.

## Process

### 1. Gather context

Ask for the parent epic id (issue number, task id, or file path depending on backend). If not in your context, fetch it with `task-backend` verb `get(id)`.

### 2. Explore the codebase (optional)

Skip if already done.

### 3. Draft vertical slices

Each task is a **tracer bullet** — a thin vertical slice cutting through all integration layers end-to-end, not a horizontal layer.

Slices are `HITL` (needs human interaction) or `AFK` (implementable unattended). Prefer AFK.

Rules:
- Each slice delivers a narrow COMPLETE path through every layer
- A completed slice is demoable on its own
- Many thin slices beat few thick ones

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice:
- **Title**
- **Type**: HITL / AFK
- **Blocked by**: which slices (if any) must complete first
- **User stories covered** (if present in the PRD)

Ask:
- Is the granularity right?
- Are dependencies correct?
- Should any slices be merged or split?
- AFK/HITL tags right?

Iterate until approved.

### 5. Create the tasks

For each approved slice, call `create_task(title, body, parent_epic=<epic_id>)`. If a slice is big enough to need sub-steps, follow with `create_subtask` calls.

Create in dependency order so you can put real ids in the `Blocked by` field.

Body template:

```md
## What to build

Concise end-to-end description. Behavior, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- <id> (if any)

Or "None — can start immediately" if no blockers.
```

Do NOT modify the parent epic.

After creation, print the resolved backend and the list of created task ids/URLs.
