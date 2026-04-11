---
name: qa
description: Interactive QA intake workflow where the user reports bugs conversationally and the agent creates durable backend-appropriate bug artifacts for `github`, `backlog`, or `local` planning. Use when user wants to report bugs, do QA, file bug tasks conversationally, or mentions "QA session".
---

# QA Session

Run an interactive QA session. The user describes problems they're encountering. You clarify just enough to make each report durable, explore the codebase in the background for context and domain language, resolve the planning backend, and create backend-appropriate bug artifacts.

Preserve the conversational QA workflow. Do not turn this into a fix-planning or implementation session unless the user asks for that separately.

## Backend resolution

Resolve the backend in this order before creating artifacts:

- explicit user instruction for the current run
- local private override in `.pi/planning.local.json`
- checked-in project default in `.pi/planning.json`

If the repo has a shared planning conventions document, follow it as the source of truth for backend behavior (for this repo, that file is `PLANNING.md`).

Supported backends are `github`, `backlog`, and `local`.

Before creating artifacts, state which backend you resolved and why.

## For each issue the user raises

### 1. Listen and lightly clarify

Let the user describe the problem in their own words. Ask **at most 2-3 short clarifying questions** focused on:

- What they expected vs what actually happened
- Steps to reproduce (if not obvious)
- Whether it's consistent or intermittent

Do NOT over-interview. If the description is clear enough to file, move on.

### 2. Explore the codebase in the background

While talking to the user, kick off an Agent (subagent_type=Explore) in the background to understand the relevant area. The goal is NOT to find a fix — it's to:

- Learn the domain language used in that area (check `UBIQUITOUS_LANGUAGE.md` if it exists)
- Understand what the feature is supposed to do
- Identify the user-facing behavior boundary

This context helps you write a better bug artifact — but the artifact itself should NOT reference specific files, line numbers, or internal implementation details.

### 3. Assess scope: single issue or breakdown?

Before filing, decide whether this is a **single issue** or needs to be **broken down** into multiple issues.

Break down when:

- The fix spans multiple independent areas (for example, "the form validation is wrong AND the success message is missing AND the redirect is broken")
- There are clearly separable concerns that different people could work on in parallel
- The user describes something that has multiple distinct failure modes or symptoms

Keep as a single issue when:

- It's one behavior that's wrong in one place
- The symptoms are all caused by the same root behavior

### 4. Create the backend-appropriate bug artifact(s)

Create the artifact(s) without asking the user to review first.

#### Backend-specific destinations

- `github`: create GitHub issue(s) with `gh issue create`
- `backlog`: create Backlog.md-native bug task(s) in the configured backlog workspace, preferably under the hidden `.backlog` root when the project uses that setup
- `local`: create local Markdown bug-planning artifact(s) under `plans/` so the workflow does not require GitHub or Backlog.md. For a single issue, create one concise bug brief file such as `plans/bug-<slug>.md`. For a breakdown, keep it minimal by creating one parent Markdown breakdown file in `plans/` with one section per issue instead of noisy child ticket files.

#### For a single issue

Use this template:

```md
## What happened

[Describe the actual behavior the user experienced, in plain language]

## What I expected

[Describe the expected behavior]

## Steps to reproduce

1. [Concrete, numbered steps a developer can follow]
2. [Use domain terms from the codebase, not internal module names]
3. [Include relevant inputs, flags, or configuration]

## Additional context

[Any extra observations from the user or from codebase exploration that help frame the issue — use domain language but don't cite files]
```

#### For a breakdown (multiple issues)

Create the artifacts in dependency order (blockers first) so later artifacts can reference real issue numbers, task IDs, or local sections.

Use this template for each sub-issue:

```md
## Parent artifact

<GitHub issue / Backlog.md task / local plan reference, or "Reported during QA session">

## What's wrong

[Describe this specific behavior problem — just this slice, not the whole report]

## What I expected

[Expected behavior for this specific slice]

## Steps to reproduce

1. [Steps specific to THIS issue]

## Blocked by

- <artifact reference> (if this issue can't be fixed until another is resolved)

Or "None — can start immediately" if no blockers.

## Additional context

[Any extra observations relevant to this slice]
```

When creating a breakdown:

- **Prefer many thin issues over few thick ones** — each should be independently fixable and verifiable
- **Mark blocking relationships honestly** — if issue B genuinely can't be tested until issue A is fixed, say so. If they're independent, mark both as "None — can start immediately"
- **Create artifacts in dependency order** so you can reference real artifact identifiers in `Blocked by`
- **Maximize parallelism** — the goal is that multiple people (or agents) can grab different issues simultaneously

#### Rules for all bug artifacts

- **No file paths or line numbers** — these go stale
- **Use the project's domain language** (check `UBIQUITOUS_LANGUAGE.md` if it exists)
- **Describe behaviors, not code** — for example, "the sync service fails to apply the patch" not "applyPatch() throws on line 42"
- **Reproduction steps are mandatory** — if you can't determine them, ask the user
- **Keep it concise** — a developer should be able to read the artifact in about 30 seconds

After creating the artifact(s), print all resulting URLs and/or local paths, summarize any blocking relationships, and ask: "Next issue, or are we done?"

### 5. Continue the session

Keep going until the user says they're done. Each issue is independent — don't batch them.
