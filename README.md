# Agent Skills

An opinionated pi workflow: two entry points, a downstream pipeline of short slash commands, and a catalog of skills that back them.

```
Install:                pi install git:github.com/frontendwizard/skills
Bootstrap a repo:       /skill:setup-project
Start a codebase task:  /skill:domain-model
Start non-code work:    /skill:grill-me

Feature pipeline:       /prd → /tasks (or /plan) → /work
Bug pipeline:           /triage → /work
QA intake:              /qa → /work
Refactor pipeline:      /refactor → /work
Decisions:              /decide
Support:                /skill:zoom-out, /skill:design-an-interface
```

## Design principles

- **One user command loads at most one skill.** No macro prompts that chain skills.
- **Two canonical entry points, quarantined behind `/skill:…`.** `domain-model` for work inside an existing codebase; `grill-me` for non-codebase plans. Both carry `disable-model-invocation: true` so they never auto-match.
- **Short slash commands for unambiguous pipeline verbs only.** `/prd`, `/tasks`, `/plan`, `/work`, `/triage`, `/qa`, `/refactor`, `/decide`, plus canonical `/domain-model` and `/grill-me`. No `/feature`, `/start`, `/design`, etc.

## Install

```bash
# global
pi install git:github.com/frontendwizard/skills

# project-local (recommended for teams — writes .pi/settings.json)
pi install -l git:github.com/frontendwizard/skills
```

Then bootstrap the repo with `/skill:setup-project`. That picks a task backend, writes `.skills/config.toml`, updates `.gitignore`, and (only when needed) appends a minimal `AGENTS.md` stanza.

## Task backend

Skills that file tracked work (PRDs, plans, bug tasks, refactor RFCs, decisions) route through a single adapter skill: **[task-backend](skills/task-backend/SKILL.md)**. It resolves the active backend from `.skills/config.toml` and exposes a uniform verb vocabulary (`create_epic`, `create_task`, `create_subtask`, `get`, `list_open`, `update`, `comment`).

Supported backends:

- `github` — GitHub Issues (via `gh`)
- `backlog-md` — [MrLesk/Backlog.md](https://github.com/MrLesk/Backlog.md) local-first tracker
- `dex` — [dex.rip](https://dex.rip)
- `local` — Markdown files under `plans/`, no tracker

Projects pick one per repo:

```toml
# .skills/config.toml
[tasks]
backend = "backlog-md"   # "github" | "backlog-md" | "dex" | "local"
```

This repo defaults to `backlog-md`. See [BACKLOG.md](BACKLOG.md) for the bootstrap and an end-to-end example.

## Skill catalog

### Planning & design

- **[to-prd](skills/to-prd/SKILL.md)** → `/prd` — feature PRD via interview + codebase exploration, filed as an epic.
- **[to-tasks](skills/to-tasks/SKILL.md)** → `/tasks` — break an epic into tracer-bullet child tasks via the task backend.
- **[to-plan](skills/to-plan/SKILL.md)** → `/plan` — break a PRD into local Markdown plan files.
- **[request-refactor-plan](skills/request-refactor-plan/SKILL.md)** → `/refactor` — refactor as tiny commits, filed as task(s).
- **[write-a-decision](skills/write-a-decision/SKILL.md)** → `/decide` — ADR-style decision records.
- **[domain-model](skills/domain-model/SKILL.md)** → `/domain-model` — grill a plan against an existing codebase's language and ADRs.
- **[grill-me](skills/grill-me/SKILL.md)** → `/grill-me` — grill a non-code plan until every decision branch is resolved.
- **[design-an-interface](skills/design-an-interface/SKILL.md)** — generate multiple radically different interface designs via parallel sub-agents.
- **[zoom-out](skills/zoom-out/SKILL.md)** — step back when stuck in the weeds.

### Development & execution

- **[do-work](skills/do-work/SKILL.md)** → `/work` — execute one scoped coding task end-to-end.
- **[triage-issue](skills/triage-issue/SKILL.md)** → `/triage` — find a bug's root cause and file a TDD-based fix.
- **[qa](skills/qa/SKILL.md)** → `/qa` — conversational QA intake.
- **[tdd](skills/tdd/SKILL.md)** — red-green-refactor loop.
- **[improve-codebase-architecture](skills/improve-codebase-architecture/SKILL.md)** — surface deepening opportunities, file as RFC.
- **[migrate-to-shoehorn](skills/migrate-to-shoehorn/SKILL.md)** — migrate test `as` assertions to `@total-typescript/shoehorn`.
- **[scaffold-exercises](skills/scaffold-exercises/SKILL.md)** — exercise directory scaffolding.

### GitHub-native

- **[github-triage](skills/github-triage/SKILL.md)** — label-based GitHub issue triage. Bypasses the task-backend adapter.

### Tooling & setup

- **[setup-project](skills/setup-project/SKILL.md)** → `/skill:setup-project` — bootstrap a repo with this package.
- **[setup-pre-commit](skills/setup-pre-commit/SKILL.md)** — Husky + lint-staged + Prettier + typecheck + tests.
- **[setup-git-guardrails](skills/setup-git-guardrails/SKILL.md)** → `/skill:setup-git-guardrails` — harness-agnostic pre-tool-call guardrail that blocks dangerous git commands (push, reset --hard, clean, branch -D, checkout ., restore .) across Claude Code, pi, and opencode from one shared pattern list.

### Writing & knowledge

- **[write-a-skill](skills/write-a-skill/SKILL.md)** — author new skills.
- **[edit-article](skills/edit-article/SKILL.md)** — restructure and tighten prose.
- **[ubiquitous-language](skills/ubiquitous-language/SKILL.md)** — extract a DDD-style glossary from conversation.
- **[obsidian-vault](skills/obsidian-vault/SKILL.md)** — search, create, and manage Obsidian vault notes.

### AFK `/do-work` loop

Inside tmux, keep launching fresh `/do-work` sessions in a right-side worker pane:

```bash
skills/do-work/scripts/afk-do-work-loop.sh [iterations]
```

Default cap is `10`. Stops on Ctrl-C, `<promise>NO MORE TASKS</promise>`, `<promise>BLOCKED</promise>`, or cap.

## Appendix: add a single skill without the package

If a repo cannot depend on a pi package, you can still copy one skill at a time:

```bash
npx skills@latest add frontendwizard/skills/<skill-name>
```

Examples:

```bash
npx skills@latest add frontendwizard/skills/to-prd
npx skills@latest add frontendwizard/skills/do-work
npx skills@latest add frontendwizard/skills/task-backend
```

The underlying resolver maps each name to `skills/<name>` in this repo.
