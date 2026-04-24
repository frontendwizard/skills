---
name: do-work
description: "Completes one scoped coding task end-to-end: understand the prompt, explore the codebase, implement the change, use TDD when writing code, validate it, and commit it. Use when the user wants an autonomous single-task implementation, says 'do the work', asks you to take something from prompt to commit, or wants minimal supervision on one concrete coding task."
---

# Do Work

Do one concrete coding task from prompt to commit with minimal supervision.

## Guardrails

- Work on exactly one task.
- If the user gives a list of tasks, choose the highest-priority task that is not blocked and do only that one.
- Infer priority from explicit priorities, dependencies, backlog order, plan phase order, or other repo signals.
- Treat tasks as blocked when they depend on unfinished prerequisite work or the prompt/backlog marks them as blocked.
- If priority or blocking cannot be determined well enough to pick one task, ask the user to clarify.
- Ask at most one focused clarifying question, and only if ambiguity blocks progress.
- Prefer the smallest complete change that satisfies the request.
- Do not sneak in unrelated refactors, drive-by fixes, or extra features.
- Do not commit if required validation is failing unless the user explicitly approves that risk.

## Workflow

### 1. Understand the task

- If given a task list, identify the highest-priority unblocked task before doing anything else.
- If no task list was given, load `task-backend/SKILL.md`, resolve the backend, and use the `list_open` verb to fetch candidates. Pick the highest-priority unblocked one.
- Restate the chosen task in one sentence.
- Identify the likely acceptance criteria.
- Identify constraints from the prompt, repo conventions, and existing code.

### 2. Explore the codebase

- Find the relevant entry points, modules, tests, and configs.
- Inspect existing patterns before changing code.
- Determine how this repo does validation by checking files like `package.json`, `pyproject.toml`, `Makefile`, `justfile`, CI workflows, or project docs.

### 3. Implement

- If the task involves writing or changing code, use TDD by default.
- Work in red-green-refactor loops: write the narrowest trustworthy failing test for the next behavior, make it pass with the smallest code change, then refactor while staying green.
- Prefer behavior-level tests through public interfaces over implementation-coupled tests.
- If the task is documentation, copy, or another change with no meaningful automated test surface, explicitly note that TDD is not applicable.
- Make the smallest coherent change that solves the task.
- Follow local conventions instead of inventing new ones.
- Keep edits scoped to the task.

### 4. Validate

Run the applicable validation layers in this order when available:

1. Format
2. Lint
3. Typecheck or static analysis
4. Tests

Validation rules:

- Use the repo's real commands, not generic guesses.
- If multiple options exist, prefer the ones used by CI or documented scripts.
- Start with the narrowest trustworthy test command, then broaden if needed.
- If a validation layer does not exist, explicitly note that.
- If validation fails, fix the issue and rerun.
- If you cannot get validation green, stop before commit and report the blocker.

### 5. Commit

Once the task is implemented and validation is green:

- Review the diff for task focus.
- Stage only the intended files.
- Match the repo's commit style by checking recent history when useful.
- If the style is unclear, use a short imperative commit message.
- Create exactly one commit for the task.

### 6. Report back

Provide a short handoff with:

- What changed
- Validation commands run and results
- Commit hash and message
- Any notable caveats or follow-up risks

## Quick start

Use this skill when the user gives a concrete coding task and wants execution, not a plan. If they give a task list, first pick the highest-priority task that is not blocked. The default path is:

`prompt -> choose one unblocked task -> understand -> explore -> (if coding, use TDD) -> validate -> commit`

For unattended tmux execution in this repo, see `do-work/scripts/afk-do-work-loop.sh` and `do-work/afk-loop-prompt.md`.
