---
name: request-refactor-plan
description: Create a detailed refactor plan with tiny commits via user interview, then file it through the project's configured task backend (epic + tasks, or a committed local plan). Use when a user wants to plan a refactor, create a refactoring RFC, or break a refactor into safe incremental steps without forcing a PRD.
---

# Request Refactor Plan

Use for refactors and other engineering changes. PRDs are usually unnecessary for this kind of work.

You may skip steps that are not needed.

## Process

1. Ask for a long, detailed description of the problem and any solution ideas.

2. Explore the repo to verify assertions and understand current state.

3. Ask whether they considered other options. Present alternatives.

4. Interview the user about implementation. Be thorough.

5. Hammer out exact scope. What changes, what doesn't.

6. Check test coverage for the affected area. If insufficient, ask about testing plans.

7. Break the implementation into tiny commits. Follow Fowler: "make each refactoring step as small as possible, so that you can always see the program working."

8. Load `task-backend/SKILL.md` and resolve the backend. State which it is and why.

9. File the plan:

- **Single-phase refactor** → `create_task(title, body)` using the template below as the body.
- **Multi-phase refactor** → `create_epic(title, summary)` then `create_task(phase_title, phase_body, parent_epic=<id>)` for each phase. For a chunky phase, add `create_subtask` calls under that phase's task.

10. Print resolved backend and all created ids/URLs.

<refactor-plan-template>

## Problem Statement

Problem from the developer's perspective.

## Solution

Solution from the developer's perspective.

## Commits

Long, detailed plan in plain English. Tiniest commits possible. Each leaves the codebase working.

## Decision Document

Modules to build/modify, interfaces, clarifications, architectural decisions, schema changes, API contracts, specific interactions.

Do NOT include file paths or code snippets.

## Testing Decisions

What makes a good test, which modules get tested, prior art.

## Out of Scope

What's out of scope.

## Further Notes (optional)

Anything else.

</refactor-plan-template>
