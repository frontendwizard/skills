---
name: setup-project
description: Bootstrap a target repo with the full workflow skill set, pick and initialize a task backend, wire `.agents/skills/`, update `.gitignore`, and append an AGENTS.md stanza. Use when the user wants to set up skills on a new or existing project, run "setup skills", wire a repo for pi/opencode, or install the workflow bundle (grill-me, request-refactor-plan, improve-codebase-architecture, to-prd, to-tasks, to-plan, do-work, tdd, zoom-out, write-a-decision, write-a-skill, domain-model, task-backend, etc.) in one go.
---

# Setup Project

Bootstrap the current repo so every workflow skill (and its task backend) is ready to use.

Pi and opencode auto-discover `.agents/skills/` inside the repo, so no editor-specific hooks are required. This skill is orchestration only.

## Workflow

Run each step interactively. Confirm with the user between irreversible actions (writing files, running CLIs).

### 1. Verify target

- Target is the current working directory. Confirm with the user: "Set up skills in `<pwd>`?"
- Detect git root. Abort if not inside a repo unless the user explicitly opts out.

### 2. Pick the skill bundle

Default bundle (the workflow set):

```
task-backend grill-me zoom-out domain-model
to-prd to-tasks to-plan request-refactor-plan improve-codebase-architecture
write-a-decision write-a-skill
triage-issue qa tdd do-work
```

Ask the user if they want to add or drop any. `task-backend` is mandatory when any of `to-prd`, `to-tasks`, `request-refactor-plan`, `triage-issue`, `qa`, `improve-codebase-architecture`, `write-a-decision`, or `do-work` are selected.

### 3. Install skills

Run `setup-project/scripts/install.sh <bundle...>`. The script copies each skill directory from this repo into `<target>/.agents/skills/`. It refuses to overwrite an existing skill unless `--force` is passed.

If the user runs this skill from a fresh clone without local access to the skill source, fall back to `npx skills@latest add frontendwizard/skills/<name>` per skill.

### 4. Pick and initialize the task backend

Ask: `github`, `backlog-md`, `dex`, or `local`?

Write `.skills/config.toml` (see [REFERENCE.md](REFERENCE.md) for the template). Then initialize:

- `github` → check `gh auth status`; if not logged in, prompt the user
- `backlog-md` → run `backlog init` (or skip if `.backlog/` already exists)
- `dex` → run `dex init` (or skip if already configured)
- `local` → ensure `plans/` exists

### 5. Update `.gitignore`

Append (create the file if missing), deduping existing lines:

```
.skills/config.local.toml
```

If backend is `backlog-md`, also append `.backlog/`.

### 6. Append to AGENTS.md

Create `AGENTS.md` if missing. Append the stanza in [REFERENCE.md](REFERENCE.md) that names the installed bundle and the resolved task backend, so other agents loading the repo discover the conventions. Skip if the stanza is already present (check for the marker line).

### 7. Report

Print:

- Skills installed (count + list)
- Backend resolved
- Files changed: `.agents/skills/*`, `.skills/config.toml`, `.gitignore`, `AGENTS.md`
- Next steps the user should run manually (e.g. `backlog init` if it was skipped, or filing a first PRD with `to-prd`)

## Rules

- Never commit. Leave the diff for the user to review.
- Never overwrite an existing skill, `AGENTS.md` section, or config without asking.
- If the user re-runs this skill, behave idempotently: update in place, skip unchanged pieces.
- If the project already has a conflicting backend config (for example `dex init` vs `[tasks].backend = "backlog-md"`), surface the conflict and ask before changing anything.
