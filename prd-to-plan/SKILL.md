---
name: prd-to-plan
description: Turn a feature PRD into backend-appropriate implementation artifacts using tracer-bullet vertical slices. Use when user wants to break down a PRD, create an implementation plan, create backend-aware tickets/tasks, or mentions "tracer bullets".
---

# PRD to Plan

Use this skill after a feature PRD already exists. Break the PRD into tracer-bullet vertical slices, then produce the right planning artifacts for the resolved backend.

If the work is truly a single slice, do not force a multi-phase plan. Create one executable ticket/task in the selected backend instead.

## Process

### 1. Confirm the PRD is in context

The PRD should already be in the conversation. If it isn't, ask the user to paste it or point you to the file.

### 2. Explore the codebase

If you have not already explored the codebase, do so to understand the current architecture, existing patterns, and integration layers.

### 3. Identify durable architectural decisions

Before slicing, identify high-level decisions that are unlikely to change throughout implementation:

- Route structures / URL patterns
- Database schema shape
- Key data models
- Authentication / authorization approach
- Third-party service boundaries

These go in the parent plan so every slice can reference them.

### 4. Draft vertical slices

Break the PRD into **tracer bullet** slices. Each slice is a thin vertical path through the system end-to-end, not a horizontal layer split.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every relevant layer
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- Do NOT include specific file names, function names, or implementation details that are likely to change
- DO include durable decisions: route paths, schema shapes, data model names, external contracts
</vertical-slice-rules>

### 5. Decide whether the work is single-slice or multi-slice

Use these rules:

- If the PRD can be delivered as one executable slice, treat it as **single-slice** work
- If the PRD needs multiple independently-executable slices, treat it as **multi-slice** work
- Do not create a parent plan artifact for single-slice work unless the user explicitly asks for one

### 6. Resolve the backend before creating artifacts

Use this precedence order:

- explicit user instruction for the current run
- local private override in `.pi/planning.local.json`
- checked-in project default in `.pi/planning.json`

If the repo has a shared planning conventions document, follow it as the source of truth for backend behavior (for this repo, that file is `PLANNING.md`).

Supported backends are `github`, `backlog`, and `local`.

### 7. Quiz the user

Present the proposed breakdown as a numbered list. For each slice show:

- **Title**: short descriptive name
- **User stories covered**: which user stories from the PRD this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Should any slices be merged or split further?

Iterate until the user approves the breakdown.

### 8. Produce backend-appropriate artifacts

#### Single-slice output

For single-slice work, create one executable ticket/task in the selected backend:

- `github`: create one GitHub issue for the slice and reference the source PRD
- `backlog`: create one Backlog.md task in the configured backlog workspace, preferably under the hidden backlog root when the project uses that setup
- `local`: do **not** create a parent plan file or a child ticket file; give the user a short local execution brief in the response and note that the eventual commit acts as the ticket

#### Multi-slice output

For multi-slice work:

1. Create a parent plan file in `./plans/`
2. Give every slice a stable slice ID such as `S1`, `S2`, `S3`
3. Treat the parent plan as the durable parent artifact for the initiative
4. Create backend-specific child tickets/tasks for each slice as follows:

- `github`: create child GitHub issues for each slice. Each issue should reference the source PRD, the parent plan file, and the slice ID.
- `backlog`: create child Backlog.md tasks for each slice. Each task should reference the source PRD, the parent plan file, and the slice ID. Model dependencies between tasks where relevant so Backlog.md can represent execution order without becoming the execution runtime.
- `local`: keep the work in the parent plan file only. Do **not** create noisy child ticket files. The plan is the durable artifact and commits act as the tickets during execution.

For multi-slice work, explicitly state which backend you resolved and why.

### 9. Keep the parent/child relationship durable

When you create multi-slice artifacts:

- the parent plan is the authoritative description of the whole initiative
- each child ticket/task must reference the parent plan and the slice ID
- each child ticket/task should also reference the source PRD
- dependency order should be expressed through slice IDs and backend-native dependency links when available

This keeps the relationship between the plan and its executable slices durable across GitHub, Backlog.md, and local workflows.

### 10. Write the parent plan file for multi-slice work

Create `./plans/` if it doesn't exist. Write the plan as a Markdown file named after the feature (for example `./plans/user-onboarding.md`). Use the template below.

<plan-template>
# Plan: <Feature Name>

> Source PRD: <brief identifier or link>

## Architectural decisions

Durable decisions that apply across all slices:

- **Routes**: ...
- **Schema**: ...
- **Key models**: ...
- (add/remove sections as appropriate)

---

## Slice 1: <Title>

**Slice ID**: `S1`
**User stories**: <list from PRD>

### What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

### Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Slice 2: <Title>

**Slice ID**: `S2`
**User stories**: <list from PRD>

### What to build

...

### Acceptance criteria

- [ ] ...

<!-- Repeat for each slice -->
</plan-template>
