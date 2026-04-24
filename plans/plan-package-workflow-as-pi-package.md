# Plan: Package the workflow as a pi package

> No PRD — this is packaging work derived from a research conversation, not feature work.

## Goal

Turn this repo into a single installable pi package so a user can run `pi install git:github.com/frontendwizard/skills` and get the full workflow. Keep discoverability high and context pollution low: one user command loads at most one SKILL.md, and the two entry points (`/domain-model`, `/grill-me`) can never be confused.

## Architectural decisions

Durable decisions that apply across all phases:

- **One user command loads at most one skill.** No macro prompt templates that chain multiple skills. No `## Next steps` cross-links inside SKILL.md. Downstream suggestions live only in the agent's plain-English reply or in `ctx.ui.notify`.
- **Two canonical entry points, quarantined behind explicit invocation.** `/domain-model` for tasks in an existing codebase; `/grill-me` for non-codebase thinking. Both carry `disable-model-invocation: true` so they never auto-match.
- **Descriptions disambiguate entry points.** `grill-me` description explicitly excludes codebase work and points to `domain-model`. Symmetric clarification on `domain-model` if needed.
- **No short aliases for ambiguous verbs.** Keep `/domain-model` and `/grill-me` at canonical names. Do not create `/grill`, `/domain`, `/start`, `/begin`, `/feature`.
- **Prompt templates map 1:1 to skills.** Short, memorable command surface for unambiguous downstream verbs only (`/prd`, `/tasks`, `/plan`, `/work`, `/triage`, `/qa`, `/refactor`, `/decide`).
- **AGENTS.md stays empty by default.** `setup-project` writes a stanza only when the repo has non-obvious facts the model cannot infer from skill/tool descriptions: ambiguous task backend, or installed extensions with a stated preference (e.g. `agent-browser`).
- **Extension, if any, is UI-only.** Any nudges use `ctx.ui.notify` / `setStatus`. Never inject workflow hints into the system prompt or into LLM-visible messages.
- **Repo-local bootstrap delegates to `pi install`.** `setup-project` stops copying skill directories. It runs `pi install -l` to add the package to project settings, then handles the parts pi doesn't: backend pick, `.skills/config.toml`, `.gitignore`, optional AGENTS.md stanza.
- **Per-skill `npx skills@latest add …` stays as an escape hatch** for repos that cannot depend on a pi package.

---

## Phase 1: Disambiguate entry points

**Task ID**: `PW-001`

### What to build

Tighten the two entry-point skills so they cannot collide and cannot auto-load.

### Changes

- `grill-me/SKILL.md` frontmatter:
  - Rewrite `description` to scope it to non-codebase artifacts (talks, articles, proposals, life decisions, external specs) and explicitly redirect codebase work to `domain-model`.
  - Add `disable-model-invocation: true`.
- `domain-model/SKILL.md` frontmatter:
  - Reread description. If it could match non-code plans, add an explicit "for existing codebases" clause.
  - Confirm `disable-model-invocation: true` is still present.
- `setup-project/SKILL.md` frontmatter:
  - Add `disable-model-invocation: true`. One-time bootstrap, should fire only on explicit invocation.

### Acceptance criteria

- [ ] `/skill:grill-me` and `/skill:domain-model` are the only ways those skills load.
- [ ] Descriptions contain non-overlapping domain qualifiers (non-codebase vs existing codebase).
- [ ] `setup-project` does not auto-match on ambient prompts.

---

## Phase 2: Restructure repo as a pi package

**Task ID**: `PW-002`

### What to build

Add the pi package manifest and move skill directories under a conventional `skills/` root so `pi install` works.

### Changes

- Add `package.json` at repo root:
  ```json
  {
    "name": "@frontendwizard/pi-workflow",
    "version": "0.1.0",
    "keywords": ["pi-package"],
    "pi": {
      "skills": ["./skills"],
      "prompts": ["./prompts"]
    }
  }
  ```
- Move existing skill directories into `skills/` (one move per skill). Keep `SKILL.md` paths intact otherwise.
- Update internal relative links that break from the move (e.g. `BACKLOG.md` references `task-backend/SKILL.md` — fix to `skills/task-backend/SKILL.md`).
- Keep `setup-project/scripts/` where it is and update internal paths.
- Verify `pi install -e .` from a fresh pi session loads every skill with no validation warnings.

### Acceptance criteria

- [ ] `pi install -e .` loads every skill successfully.
- [ ] `pi --list-skills` (or equivalent) shows all skills under their canonical names.
- [ ] No broken relative links in moved SKILL.md files.
- [ ] Existing consumers using `npx skills@latest add …` still work (the script resolves paths under `skills/`).

---

## Phase 3: Add prompt-template surface

**Task ID**: `PW-003`

### What to build

Short, unambiguous slash commands for the downstream pipeline verbs. Each template is one line that forwards to exactly one skill.

### Changes

Create `prompts/` with these files (frontmatter: `description`, `argument-hint` where useful):

- `prd.md` → loads `to-prd`
- `tasks.md` → loads `to-tasks`
- `plan.md` → loads `to-plan`
- `work.md` → loads `do-work`
- `triage.md` → loads `triage-issue`
- `qa.md` → loads `qa`
- `refactor.md` → loads `request-refactor-plan`
- `decide.md` → loads `write-a-decision`
- `domain-model.md` → loads `domain-model` (canonical name, no shorter alias)
- `grill-me.md` → loads `grill-me` (canonical name, no shorter alias)

Body template (kept trivial to avoid injecting extra context):

```markdown
---
description: <copied from skill, trimmed to one line>
argument-hint: "<from the skill if applicable>"
---
Load the `<skill-name>` skill and run it. Args: $@
```

**Not creating**: `/feature`, `/start`, `/begin`, `/grill`, `/domain`, `/plan-it`, `/design`, or any macro that chains skills.

### Acceptance criteria

- [ ] Ten prompt templates exist, one per listed skill.
- [ ] Autocomplete shows each with a distinct, non-overlapping description.
- [ ] No template body references a second skill.
- [ ] Typing `/` in pi shows all templates with argument hints where applicable.

---

## Phase 4: Rewrite README around the pipeline

**Task ID**: `PW-004`

### What to build

Lead the README with the pipeline shape and the one-line install. Move the per-skill `npx` snippets to an appendix.

### Changes

- New top-of-README structure:
  ```
  Install:                pi install git:github.com/frontendwizard/skills
  Bootstrap a repo:       /skill:setup-project
  Start a codebase task:  /skill:domain-model
  Start non-code work:    /skill:grill-me

  Feature pipeline:       /prd → /tasks (or /plan) → /work
  Bug pipeline:           /triage → /work
  Refactor pipeline:      /refactor → /work
  QA intake:              /qa → /work
  Support:                /decide, /skill:zoom-out, /skill:design-an-interface
  ```
- Keep the per-skill catalog below, each entry pointing to its SKILL.md.
- Move `npx skills@latest add …` snippets into an "Escape hatch: add a single skill without the package" appendix section.
- Keep the `BACKLOG.md` section and the `task-backend` explanation unchanged; just fix moved paths.

### Acceptance criteria

- [ ] README opens with the pipeline and install line, not with a category list.
- [ ] Every command mentioned in the pipeline maps to a prompt template or skill that exists.
- [ ] The `npx` path is still documented but demoted to an appendix.

---

## Phase 5: Rework `setup-project` to install via `pi install`

**Task ID**: `PW-005`

### What to build

Stop copying skill directories. Let pi do the install; `setup-project` handles only the repo-local wiring pi cannot.

### Changes

- `setup-project/SKILL.md`:
  - Replace step 3 ("Install skills") with: run `pi install -l git:github.com/frontendwizard/skills` (or a configurable source, e.g. npm name once published).
  - Keep step 4 (backend pick + `.skills/config.toml` write + backend-specific init).
  - Keep step 5 (`.gitignore` updates).
  - Rewrite step 6 (AGENTS.md) per Phase 6 rules — only write a stanza when needed.
- `setup-project/scripts/install.sh`:
  - Shrink to a thin wrapper that invokes `pi install -l …` and surfaces errors.
  - Keep a `--legacy-copy` flag that preserves the old behaviour for repos that cannot accept a pi package dependency.
- `setup-project/REFERENCE.md`:
  - Update the templates. Add the extension-preference allowlist mapping used in Phase 6.

### Acceptance criteria

- [ ] Running `/skill:setup-project` on a fresh repo produces: installed package in `.pi/settings.json`, `.skills/config.toml`, updated `.gitignore`, and a minimal-or-empty AGENTS.md stanza.
- [ ] Running it a second time is idempotent: no duplicate package entries, no duplicate `.gitignore` lines, no duplicate AGENTS.md stanza.
- [ ] `--legacy-copy` still works for the old flow.

---

## Phase 6: Minimal AGENTS.md behaviour

**Task ID**: `PW-006`

### What to build

`setup-project` writes an AGENTS.md stanza only when the repo has non-obvious facts the model cannot infer from skill/tool descriptions. Otherwise it leaves AGENTS.md untouched.

### Changes

- Detection logic in `setup-project`:
  - **Backend ambiguity check** — write a line `Tasks in this repo are tracked via <backend>.` only when:
    - backend is `dex`, `backlog-md`, or `github`, AND
    - the repo has conflicting signals (e.g. backend is `dex` but `.github/` exists; backend is `backlog-md` but `gh` is authenticated against a repo with open issues).
  - **Extension preference check** — read `~/.pi/agent/settings.json` and `.pi/settings.json`, look for installed packages in an allowlist maintained in `setup-project/REFERENCE.md`. For each match, append a one-line preference statement. Seed allowlist with:
    - `agent-browser` → `Prefer agent-browser for browser automation and web scraping.`
    - `dex` CLI → `Prefer the dex CLI for task updates outside of skill invocations.`
- Stanza format, marked with sentinel comments for idempotency:
  ```markdown
  <!-- pi-workflow:begin -->
  <zero or more single-line facts>
  <!-- pi-workflow:end -->
  ```
- If no facts apply, do not create the file and do not touch an existing one.
- On re-run, replace content between sentinels; never duplicate.

### Acceptance criteria

- [ ] Repo with `backend = "local"` and no preference-bearing extensions → AGENTS.md untouched.
- [ ] Repo with `backend = "dex"` + `.github/` present → stanza contains the dex line.
- [ ] Repo with `agent-browser` installed globally → stanza contains the agent-browser line.
- [ ] Re-running `setup-project` updates the stanza in place without duplication.
- [ ] No pipeline diagram, no skill list, no "start with /domain-model" prose ever appears in the stanza.

---

## Phase 7 (optional): UI-only extension

**Task ID**: `PW-007`

### What to build

Small extension that makes the workflow more discoverable without ever entering LLM context. Skip if Phase 1–6 feels sufficient.

### Changes

- `extensions/workflow.ts`:
  - On `session_start`, if `.skills/config.toml` is missing: `ctx.ui.notify("Run /skill:setup-project to bootstrap this repo.", "info")`.
  - Register `/workflow` command that prints the pipeline diagram via `ctx.ui.notify` (user-facing text, not an LLM message).
  - Register shortcut `ctrl+alt+w` → open `/workflow`.
- Hard rules enforced in review:
  - No `before_agent_start` handler that mutates `systemPrompt`.
  - No `pi.sendMessage` / `pi.sendUserMessage` that names a skill or instructs the model to `read` anything.
  - All hints go through `ctx.ui.*` exclusively.

### Acceptance criteria

- [ ] Extension loads cleanly under `pi install -e .`.
- [ ] `/workflow` prints the pipeline diagram to the UI footer, visible to the user only.
- [ ] No skill name appears in any message that enters LLM context via the extension.
- [ ] Session without `.skills/config.toml` shows the setup nudge once.

---

## Out of scope

- Publishing to npm under `@frontendwizard/pi-workflow`. Done after v0.1 of the package stabilises.
- Gallery metadata (`video`, `image`) for pi.dev — nice-to-have, separate task.
- Porting skills to `allowed-tools` frontmatter — orthogonal to packaging.
- Changing any skill's actual behaviour beyond the entry-point disambiguation in Phase 1.

## Risks

- **Moving skill dirs under `skills/`** breaks any consumer that hardcodes paths. Mitigate by keeping the existing `npx skills@latest add frontendwizard/skills/<name>` path working (the underlying resolver can map to `skills/<name>`), and by announcing the move in the README appendix.
- **Extension allowlist drift.** The extension-preference allowlist in `setup-project/REFERENCE.md` needs manual curation. Keep it short and explicit; accept that uncommon extensions won't get AGENTS.md lines.
- **Prompt-template descriptions** that drift from their SKILL.md descriptions. Add a check (manual or scripted) during release: template description must be a subset of the skill description.
