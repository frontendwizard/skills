---
name: setup-project
description: Bootstrap a target repo with the frontendwizard pi workflow — install the package via `pi install -l`, pick and initialize a task backend, write `.skills/config.toml`, update `.gitignore`, and (only when needed) append a minimal AGENTS.md stanza. Use when the user wants to set up skills on a new or existing project, run "setup skills", or wire a repo for pi.
disable-model-invocation: true
---

# Setup Project

Bootstrap the current repo so the pi workflow package is installed and its task backend is ready to use.

This skill is orchestration only. It delegates the skill install to `pi install`; it handles only the wiring pi does not: backend pick, `.skills/config.toml`, `.gitignore`, and an optional minimal AGENTS.md stanza.

## Workflow

Run each step interactively. Confirm with the user between irreversible actions.

### 1. Verify target

- Target is the current working directory. Confirm with the user: "Set up skills in `<pwd>`?"
- Detect git root. Abort if not inside a repo unless the user explicitly opts out.

### 2. Install the package

Default: install the frontendwizard workflow package into project settings so the repo is self-bootstrapping for the next agent that clones it.

```bash
pi install -l git:github.com/frontendwizard/skills
```

Alternatives to offer when relevant:

- **Global install** — `pi install git:github.com/frontendwizard/skills` (writes `~/.pi/agent/settings.json`; not shared with the team).
- **Pinned ref** — append `@<tag-or-sha>` for reproducibility.
- **Different source** — an internal fork or an npm name once published.
- **`--legacy-copy`** — for repos that cannot accept a pi package dependency. Falls back to `scripts/install.sh` which copies skill directories into `<target>/.agents/skills/`. See the script for flags.

Verify afterwards:

- `.pi/settings.json` lists the package under `packages` (project install), or `~/.pi/agent/settings.json` does (global).
- Re-running is safe: pi deduplicates package entries.

### 3. Pick and initialize the task backend

Ask: `github`, `backlog-md`, `dex`, or `local`?

Write `.skills/config.toml` (see [REFERENCE.md](REFERENCE.md) for the template). Then initialize:

- `github` → check `gh auth status`; if not logged in, prompt the user
- `backlog-md` → run `backlog init` (or skip if `.backlog/` already exists)
- `dex` → run `dex init` (or skip if already configured)
- `local` → ensure `plans/` exists

### 4. Update `.gitignore`

Append (create the file if missing), deduping existing lines:

```
.skills/config.local.toml
```

If backend is `backlog-md`, also append `.backlog/`.

### 5. Append to AGENTS.md (only when needed)

Do not write an AGENTS.md stanza by default. Only write one when the repo has **non-obvious facts the model cannot infer** from skill and tool descriptions.

Detection (run both checks, collect matching single-line facts):

**Backend ambiguity check.** Emit `Tasks in this repo are tracked via <backend>.` only when:

- backend is `dex`, `backlog-md`, or `github`, AND
- the repo shows conflicting signals — e.g. backend is `dex` but `.github/` exists; backend is `backlog-md` but `gh` is authenticated against a repo with open issues; backend is `github` but a populated `.backlog/` exists.

**Extension preference check.** Read `~/.pi/agent/settings.json` and `.pi/settings.json`. For each installed package in the allowlist (see [REFERENCE.md](REFERENCE.md)), append the matching one-line preference statement. Seed allowlist:

- `agent-browser` → `Prefer agent-browser for browser automation and web scraping.`
- `dex` CLI → `Prefer the dex CLI for task updates outside of skill invocations.`

If no facts apply: do **not** create the file; do **not** touch an existing one.

Stanza format, with sentinel comments for idempotency:

```markdown
<!-- pi-workflow:begin -->
<zero or more single-line facts>
<!-- pi-workflow:end -->
```

On re-run, replace the content between the sentinels verbatim — never duplicate the block, never emit two blocks, never leave stale facts. Leave everything outside the sentinels untouched. If the recomputed fact list is empty and a stanza exists, remove the sentinel block entirely.

**Never** write a pipeline diagram, skill list, or "start with /domain-model" prose into the stanza. Those live in descriptions and prompt templates; duplicating them pollutes model context.

### 6. Report

Print:

- Package installed (source + target settings file)
- Backend resolved + any initialisation run
- Files changed: `.pi/settings.json` (or global), `.skills/config.toml`, `.gitignore`, and `AGENTS.md` only if the stanza was written
- Next steps the user should run manually (e.g. `backlog init` if it was skipped, or filing a first PRD with `/prd`)

## Rules

- Never commit. Leave the diff for the user to review.
- Never overwrite an existing config without asking.
- Idempotent on re-run: update in place, skip unchanged pieces, deduplicate.
- If the project already has a conflicting backend config (for example `dex init` vs `[tasks].backend = "backlog-md"`), surface the conflict and ask before changing anything.
- If the user explicitly asks for a legacy per-skill copy, use `scripts/install.sh --legacy-copy` and skip step 2's `pi install` call.
