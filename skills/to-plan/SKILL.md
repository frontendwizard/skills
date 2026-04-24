---
name: to-plan
description: Local-Markdown PRD breakdown that turns a feature PRD into independently-grabbable plan files using tracer-bullet vertical slices. Use when user wants direct PRD-to-plan-file fan-out, wants a local planning workflow, wants to break down a PRD into Markdown files, or mentions "tracer bullets".
---

# To Plan

This is the local-Markdown sibling of `to-issues`.

Use it when the project wants planning artifacts to live as Markdown files in the repo instead of GitHub issues.

Break a PRD into independently-grabbable local Markdown plan files using vertical slices (tracer bullets).

## Process

### 1. Gather context

Ask the user for the PRD file path, a pasted PRD, or enough context to locate the PRD in the repo.

If the PRD only exists in GitHub and the user wants GitHub issue fan-out, stop and route them to `to-issues` instead.

If the PRD is not already in your context window, read the PRD file before continuing.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the PRD into **tracer bullet** slices. Each slice is a thin vertical slice that cuts through ALL relevant integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer that matters for that slice
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- Keep the slice description durable; avoid file names and implementation details that are likely to change
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Create the local Markdown plan files

Create durable local planning artifacts in `plans/`.

#### Single-slice output

If the work only needs one slice, create one Markdown plan file in `plans/` and stop there.

#### Multi-slice output

If the work needs multiple slices:

1. Create a parent plan file in `plans/` named after the feature (for example `plans/user-onboarding.md`)
2. Create one child slice file per approved slice in a sibling folder such as `plans/user-onboarding/`
3. Write child files in dependency order (blockers first) so later slices can reference real file paths and slice IDs

Use the templates below.

<parent-plan-template>
# Plan: <Feature Name>

> Source PRD: <path or identifier>

## Summary

A short description of the implementation effort.

## Slices

1. **S1 — <Title>** (`AFK`)
   - File: `plans/<feature-slug>/S1-<slice-slug>.md`
   - Blocked by: None
2. **S2 — <Title>** (`HITL`)
   - File: `plans/<feature-slug>/S2-<slice-slug>.md`
   - Blocked by: `S1`

## Durable decisions

- **Routes**: ...
- **Schema**: ...
- **Key models**: ...
- **External contracts**: ...

</parent-plan-template>

<slice-file-template>
# <Slice Title>

> Parent plan: `plans/<feature>.md`
> Slice ID: `S1`
> Type: `AFK`

## User stories covered

- <user story references>

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- None - can start immediately

Or reference earlier slice files, for example:

- `plans/<feature-slug>/S1-<slice-slug>.md`

</slice-file-template>

Do NOT delete or rewrite the source PRD unless the user explicitly asks for that.
