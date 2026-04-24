# Setup Project — reference

## Default bundle rationale

| Skill | Role |
| --- | --- |
| `task-backend` | Backend abstraction used by every task-filing skill. Mandatory. |
| `grill-me` | Stress-test plans before writing a PRD. |
| `zoom-out` | Step back when stuck in the weeds. |
| `domain-model` | Extract the domain model from a problem space. |
| `to-prd` | Create a feature PRD as an epic. |
| `to-tasks` | Break a PRD epic into tracer-bullet tasks. |
| `to-plan` | Break a PRD into a committed local Markdown plan. |
| `request-refactor-plan` | File a refactor plan as task(s). |
| `improve-codebase-architecture` | Surface deepening opportunities, file as RFC. |
| `write-a-decision` | ADR-style decision records. |
| `write-a-skill` | Author new skills. |
| `triage-issue` | Triage a bug, file a TDD fix plan. |
| `qa` | Conversational QA intake. |
| `tdd` | Red-green-refactor loop. |
| `do-work` | Execute one unblocked task end-to-end. |

Optional additions depending on project type: `setup-pre-commit`, `setup-git-guardrails`, `scaffold-exercises`, `migrate-to-shoehorn`, `edit-article`, `obsidian-vault`, `ubiquitous-language`, `design-an-interface`, `github-triage`.

## `.skills/config.toml` template

```toml
# Skills configuration for this repo.
# See task-backend/SKILL.md for the schema and behavior.

[tasks]
backend = "<github|backlog-md|dex|local>"

[tasks.github]
# repo = "owner/name"   # optional; gh auto-detects if empty

[tasks.backlog-md]
root = ".backlog"

[tasks.dex]
# dex auto-detects project; no keys required

[tasks.local]
plans_dir = "plans"
```

## AGENTS.md stanza

Sentinels for idempotent replace. On re-run, replace everything strictly between the sentinels; never duplicate, never emit two blocks.

```md
<!-- pi-workflow:begin -->
<zero or more single-line facts>
<!-- pi-workflow:end -->
```

Write the stanza **only** when at least one fact applies. If the recomputed fact list is empty and a stanza already exists, remove the sentinel block entirely.

### Fact sources

**Backend ambiguity fact.** Emit only when the configured backend is `dex`, `backlog-md`, or `github` **and** the repo shows conflicting signals that would mislead a reader:

| Configured backend | Conflicting signal | Fact to emit |
| --- | --- | --- |
| `dex` | `.github/` exists (issues/workflows) | `Tasks in this repo are tracked via dex (not GitHub Issues).` |
| `backlog-md` | `gh` authenticated on a repo with open issues | `Tasks in this repo are tracked via backlog-md (not GitHub Issues).` |
| `github` | populated `.backlog/` exists | `Tasks in this repo are tracked via GitHub Issues (not backlog-md).` |

When backend is `local`, or when there is no conflicting signal, emit nothing.

**Extension preference facts.** Read `~/.pi/agent/settings.json` and `.pi/settings.json`. For each installed package matching the allowlist, emit the corresponding line.

| Installed package | Fact |
| --- | --- |
| `agent-browser` | `Prefer agent-browser for browser automation and web scraping.` |
| `dex` CLI (globally installed binary on PATH) | `Prefer the dex CLI for task updates outside of skill invocations.` |

Keep the allowlist short and explicit. Uncommon extensions do not get AGENTS.md lines — their own descriptions carry their trigger conditions.

### Never write

Do not write these into the stanza, ever:

- Pipeline diagrams (`/prd → /tasks → /work`)
- Skill lists or catalogs
- "Start with `/domain-model`" prose
- The package name or install instructions

Those live in descriptions, prompt templates, and the README. Duplicating them into AGENTS.md pollutes model context on every turn.

## `.gitignore` additions

Always:

```
.skills/config.local.toml
```

If backend is `backlog-md`:

```
.backlog/
```

## Backend init commands

| Backend | Init |
| --- | --- |
| `github` | `gh auth status` (interactive login if needed) |
| `backlog-md` | `backlog init` |
| `dex` | `dex init` |
| `local` | `mkdir -p plans` |
