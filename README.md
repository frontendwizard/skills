# Agent Skills

A collection of agent skills that extend capabilities across planning, development, and tooling.

## Planning backends

Portable planning skills in this repo are converging on a shared backend model with three supported backends: `github`, `backlog`, and `local`.

This repo defaults to `backlog` as a private GitHub-issues replacement. Work tracking lives in the selected backend, while execution stays in pi sessions or your own scripts.

See [PLANNING.md](PLANNING.md) for the source of truth, backend precedence rules, artifact model, and the recommended hidden `.backlog` symlink setup.

## Planning & Design

These skills help you think through problems before writing code. Portable planning skills follow the repo's backend model (`github`, `backlog`, `local`) unless they are explicitly marked as GitHub-specific.

- **to-prd** — Create a feature PRD through an interactive interview, codebase exploration, and module design, then route it to the project's planning backend.

  ```
  npx skills@latest add mattpocock/skills/to-prd
  ```

- **prd-to-plan** — Turn a feature PRD into backend-appropriate implementation artifacts using tracer-bullet vertical slices.

  ```
  npx skills@latest add mattpocock/skills/prd-to-plan
  ```

- **to-issues** — GitHub-only tracer-bullet breakdown for repos that want direct PRD -> issue fan-out.

  ```
  npx skills@latest add mattpocock/skills/to-issues
  ```

- **grill-me** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.

  ```
  npx skills@latest add mattpocock/skills/grill-me
  ```

- **design-an-interface** — Generate multiple radically different interface designs for a module using parallel sub-agents.

  ```
  npx skills@latest add mattpocock/skills/design-an-interface
  ```

- **request-refactor-plan** — Create a detailed backend-aware refactor plan with tiny commits via user interview. Refactors usually do not need a PRD.

  ```
  npx skills@latest add mattpocock/skills/request-refactor-plan
  ```

## Development

These skills help you write, refactor, and fix code.

- **tdd** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.

  ```
  npx skills@latest add mattpocock/skills/tdd
  ```

- **triage-issue** — Investigate a bug by exploring the codebase, identify the root cause, and create a backend-aware bug-fix plan. Bug-fix planning does not require a PRD.

  ```
  npx skills@latest add mattpocock/skills/triage-issue
  ```

- **improve-codebase-architecture** — Explore a codebase for architectural improvement opportunities, focusing on deepening shallow modules and improving testability, then land the chosen refactor RFC in the planning backend.

  ```
  npx skills@latest add mattpocock/skills/improve-codebase-architecture
  ```

- **migrate-to-shoehorn** — Migrate test files from `as` type assertions to @total-typescript/shoehorn.

  ```
  npx skills@latest add mattpocock/skills/migrate-to-shoehorn
  ```

- **scaffold-exercises** — Create exercise directory structures with sections, problems, solutions, and explainers.

  ```
  npx skills@latest add mattpocock/skills/scaffold-exercises
  ```

- **do-work** — Execute one scoped coding task end-to-end: understand it, explore the codebase, implement it, validate it, and commit it.

  ```
  npx skills@latest add mattpocock/skills/do-work
  ```

## GitHub-Native Governance

These workflows are intentionally GitHub-specific and are not routed through the portable planning backend model.

- **github-triage** — Triage GitHub issues through a label-based state machine and prepare issues for human or agent execution.

  ```
  npx skills@latest add mattpocock/skills/github-triage
  ```

## Tooling & Setup

- **setup-pre-commit** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.

  ```
  npx skills@latest add mattpocock/skills/setup-pre-commit
  ```

- **git-guardrails-claude-code** — Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, etc.) before they execute.

  ```
  npx skills@latest add mattpocock/skills/git-guardrails-claude-code
  ```

## Writing & Knowledge

- **write-a-skill** — Create new skills with proper structure, progressive disclosure, and bundled resources.

  ```
  npx skills@latest add mattpocock/skills/write-a-skill
  ```

- **edit-article** — Edit and improve articles by restructuring sections, improving clarity, and tightening prose.

  ```
  npx skills@latest add mattpocock/skills/edit-article
  ```

- **ubiquitous-language** — Extract a DDD-style ubiquitous language glossary from the current conversation.

  ```
  npx skills@latest add mattpocock/skills/ubiquitous-language
  ```

- **obsidian-vault** — Search, create, and manage notes in an Obsidian vault with wikilinks and index notes.

  ```
  npx skills@latest add mattpocock/skills/obsidian-vault
  ```
