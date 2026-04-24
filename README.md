# Agent Skills

A collection of agent skills that extend capabilities across planning, development, and tooling.

## Task backend

Skills that file tracked work (PRDs, plans, bug tasks, refactor RFCs, decisions) route through a single adapter skill: **[task-backend](task-backend/SKILL.md)**. It resolves the active backend from `.skills/config.toml` and exposes a uniform verb vocabulary (`create_epic`, `create_task`, `create_subtask`, `get`, `list_open`, `update`, `comment`).

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

See [task-backend/SKILL.md](task-backend/SKILL.md) for the full schema and per-backend recipes.

This repo defaults to `backlog-md`. See [BACKLOG.md](BACKLOG.md) for the Backlog.md bootstrap and an end-to-end example.

## Planning & Design

These skills help you think through problems before writing code. Planning skills that file tracked work route through the [task-backend](task-backend/SKILL.md) adapter so they work with any supported backend.

- **to-prd** — Create a feature PRD through an interactive interview, codebase exploration, and module design, then file it as an epic.

  ```
  npx skills@latest add frontendwizard/skills/to-prd
  ```

- **write-a-decision** — Create a durable ADR-style decision record and land it in the project's decision store, including Backlog.md decisions in backlog-first repos.

  ```
  npx skills@latest add frontendwizard/skills/write-a-decision
  ```

- **to-plan** — Turn a feature PRD into independently-grabbable local Markdown plan files using tracer-bullet vertical slices.

  ```
  npx skills@latest add frontendwizard/skills/to-plan
  ```

- **to-tasks** — Break a PRD (already filed as an epic) into tracer-bullet child tasks via the project's configured task backend.

  ```
  npx skills@latest add frontendwizard/skills/to-tasks
  ```

- **grill-me** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.

  ```
  npx skills@latest add frontendwizard/skills/grill-me
  ```

- **design-an-interface** — Generate multiple radically different interface designs for a module using parallel sub-agents.

  ```
  npx skills@latest add frontendwizard/skills/design-an-interface
  ```

- **request-refactor-plan** — Break a refactor into tiny commits via user interview and file it as a task (or epic + phase tasks). Refactors usually do not need a PRD.

  ```
  npx skills@latest add frontendwizard/skills/request-refactor-plan
  ```

## Development

These skills help you write, refactor, and fix code.

- **tdd** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.

  ```
  npx skills@latest add frontendwizard/skills/tdd
  ```

- **triage-issue** — Investigate a bug by exploring the codebase, identify the root cause, and file a TDD-based bug-fix task. Bug-fix planning does not require a PRD.

  ```
  npx skills@latest add frontendwizard/skills/triage-issue
  ```

- **qa** — Interactive QA intake that turns user-reported bugs into durable bug tasks through the project's configured task backend.

  ```
  npx skills@latest add frontendwizard/skills/qa
  ```

- **improve-codebase-architecture** — Explore a codebase for architectural improvement opportunities, focusing on deepening shallow modules and improving testability, then file the chosen refactor RFC.

  ```
  npx skills@latest add frontendwizard/skills/improve-codebase-architecture
  ```

- **migrate-to-shoehorn** — Migrate test files from `as` type assertions to @total-typescript/shoehorn.

  ```
  npx skills@latest add frontendwizard/skills/migrate-to-shoehorn
  ```

- **scaffold-exercises** — Create exercise directory structures with sections, problems, solutions, and explainers.

  ```
  npx skills@latest add frontendwizard/skills/scaffold-exercises
  ```

- **do-work** — Execute one scoped coding task end-to-end: understand it, explore the codebase, implement it with TDD when coding, validate it, and commit it.

  ```
  npx skills@latest add frontendwizard/skills/do-work
  ```

### AFK `/do-work` loop

Inside tmux, you can run the checked-in AFK loop to keep launching fresh `/do-work` sessions in a right-side worker pane:

```bash
do-work/scripts/afk-do-work-loop.sh [iterations]
```

The default iteration cap is `10`. The loop stops on Ctrl-C, when the worker reports `<promise>NO MORE TASKS</promise>`, when it reports `<promise>BLOCKED</promise>`, or when the iteration cap is reached.

## GitHub-Native Workflows

These workflows are intentionally GitHub-specific and bypass the task-backend adapter.

- **github-triage** — Triage GitHub issues through a label-based state machine and prepare issues for human or agent execution. GitHub-only.

  ```
  npx skills@latest add frontendwizard/skills/github-triage
  ```

## Tooling & Setup

- **setup-project** — Bootstrap a target repo with the workflow skill bundle, pick and initialize a task backend, update `.gitignore`, and append an `AGENTS.md` stanza. Idempotent.

  ```
  npx skills@latest add frontendwizard/skills/setup-project
  ```

- **setup-pre-commit** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.

  ```
  npx skills@latest add frontendwizard/skills/setup-pre-commit
  ```

- **git-guardrails-claude-code** — Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, etc.) before they execute.

  ```
  npx skills@latest add frontendwizard/skills/git-guardrails-claude-code
  ```

## Writing & Knowledge

- **write-a-skill** — Create new skills with proper structure, progressive disclosure, and bundled resources.

  ```
  npx skills@latest add frontendwizard/skills/write-a-skill
  ```

- **edit-article** — Edit and improve articles by restructuring sections, improving clarity, and tightening prose.

  ```
  npx skills@latest add frontendwizard/skills/edit-article
  ```

- **ubiquitous-language** — Extract a DDD-style ubiquitous language glossary from the current conversation.

  ```
  npx skills@latest add frontendwizard/skills/ubiquitous-language
  ```

- **obsidian-vault** — Search, create, and manage notes in an Obsidian vault with wikilinks and index notes.

  ```
  npx skills@latest add frontendwizard/skills/obsidian-vault
  ```
