---
name: to-prd
description: Create a feature PRD through user interview, codebase exploration, and module design, then route it to the project's planning backend. Use when user wants a product requirements document for feature work, wants to shape feature user stories, or needs a backend-aware PRD for github, backlog, or local planning.
---

Use this skill for feature work. Refactors, bug fixes, maintenance, and other engineering tasks usually do not need a PRD and can go straight to planning or tickets.

You may skip steps if you don't consider them necessary.

## Process

1. Ask the user for a long, detailed description of the problem they want to solve and any potential ideas for solutions.

2. Explore the repo to verify their assertions and understand the current state of the codebase.

3. Interview the user relentlessly about every aspect of this plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

4. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

5. Resolve the output backend before writing the final artifact. Use this precedence order:

- explicit user instruction for the current run
- local private override in `.pi/planning.local.json`
- checked-in project default in `.pi/planning.json`

If the repo has a shared planning conventions document, follow it as the source of truth for backend behavior (for this repo, that file is `PLANNING.md`).

Supported backends are `github`, `backlog`, and `local`.

6. Once you have a complete understanding of the problem and solution, use the template below to write the PRD and land it in the backend-appropriate shape:

- `github`: create a GitHub issue containing the PRD. Use this when the project tracks feature planning in GitHub.
- `backlog`: create a PRD markdown document in the Backlog.md workspace. Prefer the hidden backlog root from config (for this repo, `.backlog`) so the PRD lives in the private local-first planning store instead of normal repo history.
- `local`: create a PRD markdown file in the repo, usually under `plans/`, for later planning and execution without creating separate remote tickets.

7. Before finalizing, state which backend you resolved and why.

Keep PRDs focused on feature requirements and user stories. If the work is a refactor, bug fix, maintenance task, or other engineering change, say that a PRD is unnecessary and route the user toward planning or tickets instead.

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
