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

Optional additions depending on project type: `setup-pre-commit`, `git-guardrails-claude-code`, `scaffold-exercises`, `migrate-to-shoehorn`, `edit-article`, `obsidian-vault`, `ubiquitous-language`, `design-an-interface`, `github-triage`.

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

Marker line so the setup skill can detect prior runs: `<!-- frontendwizard/skills:setup -->`.

```md
<!-- frontendwizard/skills:setup -->
## Agent skills

This repo uses the [frontendwizard/skills](https://github.com/frontendwizard/skills) bundle. Skills live in `.agents/skills/` and are auto-discovered by pi and opencode.

Installed bundle: <comma-separated list>

Task backend: `<github|backlog-md|dex|local>` (configured in `.skills/config.toml`). Task-filing skills route through `task-backend` — they call verbs (`create_epic`, `create_task`, `create_subtask`, etc.) instead of hardcoding CLI commands.

Useful entry points:

- `to-prd` — feature PRD as an epic
- `to-tasks` — break an epic into tracer-bullet tasks
- `to-plan` — break a PRD into a local Markdown plan
- `request-refactor-plan` — file a refactor as task(s)
- `triage-issue` / `qa` — bug intake
- `do-work` — execute one unblocked task end-to-end
- `tdd` — red-green-refactor loop
- `write-a-decision` — ADR-style decision records
<!-- /frontendwizard/skills:setup -->
```

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
