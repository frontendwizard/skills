---
name: qa
description: Interactive QA intake where the user reports bugs conversationally and the agent files durable bug tasks through the project's configured task backend. Use when the user wants to report bugs, do QA, file bug tasks conversationally, or mentions "QA session". Works with github, backlog-md, dex, or local per `.skills/config.toml`.
---

# QA Session

Run an interactive QA session. The user describes problems; you clarify just enough to make each report durable, explore the codebase in the background for context and domain language, and file backend-appropriate bug tasks.

Preserve the conversational QA workflow. Do not turn this into a fix-planning session unless the user asks separately.

## Backend

Load `task-backend/SKILL.md` once at the start of the session. Resolve the backend and state which it is. Use the `create_task` verb (or `create_epic` + `create_task` for a breakdown with a shared parent) for everything below.

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

### 4. File the bug task(s)

File without asking for review. For a single issue, call `create_task(title, body)`. For a breakdown, either file each as a sibling `create_task` with `Blocked by` references in the body, or group them by calling `create_epic` first and making each child a `create_task(..., parent_epic=<id>)`.

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

File in dependency order so later tasks can reference real ids in `Blocked by`.

Use this body template for each sub-issue:

```md
## Parent

<epic id, or "Reported during QA session" if no shared parent>

## What's wrong

[Describe this specific behavior problem — just this slice, not the whole report]

## What I expected

[Expected behavior for this specific slice]

## Steps to reproduce

1. [Steps specific to THIS issue]

## Blocked by

- <id> (if this issue can't be fixed until another is resolved)

Or "None — can start immediately" if no blockers.

## Additional context

[Any extra observations relevant to this slice]
```

When creating a breakdown:

- **Prefer many thin issues over few thick ones** — each should be independently fixable
- **Mark blocking relationships honestly**
- **File in dependency order** so you can reference real ids in `Blocked by`
- **Maximize parallelism** — multiple people or agents should be able to grab different issues simultaneously

#### Rules for all bug tasks

- **No file paths or line numbers** — these go stale
- **Use the project's domain language** (check `UBIQUITOUS_LANGUAGE.md` if it exists)
- **Describe behaviors, not code**
- **Reproduction steps are mandatory**
- **Keep it concise** — a developer should read it in ~30s

After filing, print the resulting ids/URLs, summarize any blocking relationships, and ask: "Next issue, or are we done?"

### 5. Continue the session

Keep going until the user says they're done. Each issue is independent — don't batch them.
