# Backlog.md setup for this repo

This repo dogfoods the `backlog` planning backend.

The supported local-first shape is:

- `.backlog` at the repo root
- `.backlog/` gitignored
- `.backlog` as a normal local directory by default
- execution happening in pi sessions or your own local loop, not inside Backlog.md itself

That keeps task state out of normal repo history while still giving skills a stable repo-root path to discover.

## What is committed vs private

### Committed

These files describe how the repo should behave:

- `.pi/planning.json` — checked-in project default (`backlog`)
- `PLANNING.md` — shared planning conventions and backend precedence
- `plans/*.md` — durable parent plans for multi-slice work when needed

### Private / local-only

These files are expected to stay out of commits:

- `.backlog/` — the Backlog.md workspace and all task state
- `.pi/planning.local.json` — optional per-user backend override

## One-time setup

1. Create the local workspace at the repo root.

   ```bash
   mkdir -p .backlog/{tasks,docs,decisions,drafts,archive,completed,milestones}
   ```

2. Verify it is ignored by git.

   ```bash
   git check-ignore -v .backlog
   ```

Expected result:

- `.backlog/` exists as a normal local directory
- `git check-ignore -v .backlog` shows the `.gitignore` rule that keeps the workspace out of commits

If someone wants stronger physical separation later, they can still replace `.backlog` with a symlink, but that is optional and not the default recommendation for this repo.

## Repo defaults

This repo is already configured to discover the hidden backlog root:

```json
{
  "version": 1,
  "defaultBackend": "backlog",
  "backlogRoot": ".backlog"
}
```

That lives in `.pi/planning.json`.

The matching gitignore rule is:

```gitignore
.backlog/
.pi/planning.local.json
```

## Concrete example: this initiative in Backlog.md-first mode

For the per-project planning backends initiative, the durable artifacts should be split like this:

| Artifact | Example path | Purpose |
| --- | --- | --- |
| PRD | `.backlog/docs/prd-support-per-project-planning-backends.md` | Feature requirements stay in the private backlog workspace |
| Parent plan | `plans/per-project-planning-backends-implementation-plan.md` | Shared multi-slice implementation breakdown |
| Child tickets | `.backlog/tasks/pb-001 - ...` through `.backlog/tasks/pb-006 - Clean-up-naming-and-catalog-copy-for-planning-backends.md` | Executable slices tracked in Backlog.md |
| Execution | pi session or custom loop | Actual implementation work happens outside the tracking backend |

That means the plan becomes executable Backlog.md tasks without turning Backlog.md into the execution runtime.

### Example task sequence

For this initiative, a maintainer can think about the work like this:

1. `write-a-prd` creates the feature PRD in `.backlog/docs/`
2. `prd-to-plan` creates `plans/per-project-planning-backends-implementation-plan.md`
3. The plan turns into Backlog.md tasks such as:
   - `PB-001` establish shared planning conventions
   - `PB-002` make `write-a-prd` backend-aware
   - `PB-003` make `prd-to-plan` backend-aware
   - `PB-004` align non-PRD planning flows
   - `PB-005` set up Backlog.md integration and examples for this repo
   - `PB-006` clean up naming and catalog copy for planning backends
4. A pi session or custom script picks the highest-priority unblocked task
5. `do-work` (or an equivalent prompt loop) implements exactly that one task and creates the commit
6. The backlog task status is updated locally in `.backlog/`, while the code change is recorded in git

## Minimal execution loop

You do not need extra orchestration to use this setup.

A simple manual loop is enough:

1. Read the next unblocked task from `.backlog/tasks/`
2. Read the relevant plan and recent commits
3. Ask pi to do exactly that one task
4. Validate and commit the code change
5. Mark the task done in Backlog.md

A custom script can automate those same steps, but the important boundary stays the same: Backlog.md tracks the work; pi executes the work.
