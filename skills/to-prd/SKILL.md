---
name: to-prd
description: Create a feature PRD through user interview, codebase exploration, and module design, then file it as an epic via the project's configured task backend. Use when the user wants a product requirements document for feature work, wants to shape feature user stories, or needs a backend-agnostic PRD that works with github, backlog-md, dex, or local.
---

# To PRD

Use for feature work. Refactors, bug fixes, and maintenance usually do not need a PRD — route those to `request-refactor-plan` or `triage-issue`.

You may skip steps that are not needed.

## Process

1. Ask the user for a long, detailed problem description and any solution ideas.

2. Explore the repo to verify their assertions and understand current state.

3. Interview the user relentlessly about every branch of the design tree until you reach shared understanding.

4. Sketch the major modules to build or modify. Actively look for deep modules that can be tested in isolation. Check with the user whether these match their expectations and which ones they want tests for.

5. Load `task-backend/SKILL.md`, resolve the backend, and state which it is and why.

6. Write the PRD using the template below, then call `create_epic(title, body)`. The returned id is the parent epic for any follow-up `to-tasks` run.

7. Print the epic id/URL.

<prd-template>

## Problem Statement

The problem from the user's perspective.

## Solution

The solution from the user's perspective.

## User Stories

A long, numbered list in the format:

1. As an <actor>, I want <feature>, so that <benefit>

Example:

1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending.

Cover all aspects of the feature.

## Implementation Decisions

Modules to build/modify, interfaces, technical clarifications, architectural decisions, schema changes, API contracts, specific interactions.

Do NOT include file paths or code snippets — they go stale fast.

## Testing Decisions

What makes a good test (external behavior, not implementation details), which modules will be tested, prior art in the codebase.

## Out of Scope

Things out of scope for this PRD.

## Further Notes

Anything else.

</prd-template>
