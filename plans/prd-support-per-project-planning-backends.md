# PRD: Support per-project planning backends (GitHub, Backlog.md, local)

## Problem Statement

As the maintainer of this skills repo, I want planning and work-tracking skills to support different backends on a per-project basis, so I can work privately in local-first projects without creating GitHub issue noise for collaborators.

Today, several planning skills assume GitHub issues are the default destination. That works for public collaboration, but it breaks down when I want a private backlog, lightweight local planning, or a workflow that stays outside the repository's committed files.

We briefly explored Taskplane as a replacement, but that surfaced a mismatch: Taskplane is not just a task store, it is also an orchestration runtime with its own execution model, dashboard, and agent supervision flow. My actual need is narrower. I want a replacement for GitHub issues, not a system that takes over execution. I want to keep the execution side in pi using either:

- a human-in-the-loop `do-work` style flow, or
- a simple custom loop/script that feeds the agent backlog context, recent commits, and a prompt until the work is done.

The repo needs a durable planning model that separates **where work is tracked** from **how work is executed**.

## Solution

Introduce a backend-aware planning and work-tracking model for portable planning skills.

Each project should be able to choose one of three supported backends:

- **GitHub** — remote issue-based planning and task tracking
- **Backlog.md** — private local task management using Backlog.md tasks, docs, and decisions
- **Local** — minimal local Markdown planning with commits acting as the tickets

For local-first issue replacement, Backlog.md should be the primary non-GitHub backend.

### Backlog.md mode

Backlog.md should be treated as a **GitHub issues replacement**, not as an execution runtime. In this mode:

- planning and ticket tracking happen through Backlog.md primitives
- execution still happens in pi or a custom local automation loop
- the backlog should be kept **outside the repository history** to reduce noise and reduce the chance of models loading backlog artifacts incidentally
- the recommended setup is a gitignored hidden project path such as `.backlog` as a normal local directory by default
- a symlink to an external directory remains an optional stronger-isolation setup, not the default recommendation

This gives the repo a local project board and browser while keeping the backlog private and out of committed source control.

### Artifact model

The planning model should distinguish clearly between:

- **PRD** — product requirements for feature work and user stories
- **Plan** — implementation breakdown
- **Task/Ticket** — executable unit of work
- **Execution** — how the agent actually performs the work, which remains outside the tracking backend abstraction

### Scope rules

- **PRDs are for feature work** and user-story-driven product requirements
- **Refactors, bug fixes, maintenance, and similar engineering work** do not require PRDs
- If a plan results in **one executable slice**, it can be represented as a single task/ticket
- If a plan results in **multiple slices**, it should produce a parent plan artifact plus child tickets/tasks in the selected backend

### Backend expectations

- **GitHub mode** should continue to use GitHub issues for parent/child planning and work tracking
- **Backlog.md mode** should use Backlog.md-native artifacts for tickets and related planning material, while keeping the backlog out of committed history through a gitignored hidden location such as `.backlog`
- **Local mode** should stay minimal: a local Markdown plan for multi-slice work, with commits acting as the tickets and no separate local ticket files

Portable planning skills should emit the right artifacts for the selected backend while preserving one coherent user flow. GitHub-native maintainer workflows should remain GitHub-specific.

## User Stories

1. As a repo owner, I want to choose GitHub, Backlog.md, or local planning per project, so that each repo can use the workflow that fits its collaboration style.
2. As a developer working in a shared repo, I want a private local-first issue replacement, so that I can organize work without creating noise for teammates.
3. As a solo maintainer, I want to use Backlog.md as my local board, so that I can replace GitHub issues without adopting a new execution runtime.
4. As a developer, I want planning and execution to be separate concerns, so that I can keep using pi and my own loops while changing only the work-tracking backend.
5. As a developer, I want a checked-in project default for planning behavior, so that each repo has a clear expected workflow.
6. As a developer, I want a gitignored local override, so that I can privately change planning behavior without affecting collaborators.
7. As a developer, I want to override the backend for a single run with an explicit instruction, so that I can experiment without changing config.
8. As a user of planning skills, I want the same planning skill names to work across supported backends when the conceptual job is the same, so I do not need a separate skill catalog for each storage backend.
9. As a maintainer, I want GitHub-native governance and triage skills to remain GitHub-specific, so that repository maintenance workflows stay explicit.
10. As a product-minded developer, I want to create PRDs only for feature work, so that user-story requirements remain distinct from implementation planning.
11. As an engineer planning a refactor, I want to create a plan without being forced through a PRD flow, so that non-product work stays lightweight.
12. As a developer planning a small change, I want a single-slice plan to become a single ticket, so that the workflow stays simple when the work is small.
13. As a developer planning a larger initiative, I want a multi-slice plan to produce a parent plan artifact plus child tickets, so that I can understand the whole effort and still execute it slice by slice.
14. As a Backlog.md user, I want my backlog to live outside the repo's committed files, so that I can keep task state private and reduce incidental model context loading.
15. As a Backlog.md user, I want to access the backlog through a hidden project path like `.backlog`, so that the integration still works naturally from the repo root.
16. As a Backlog.md user, I want the option for the hidden backlog path to point to an external directory, so that I can choose stronger physical separation when I need it.
17. As a developer, I want the recommended Backlog.md setup to be gitignored, so that backlog artifacts never show up in commits unless I explicitly choose otherwise.
18. As a developer, I want the skills repo to document how Backlog.md fits with a manual or scripted pi workflow, so that the tool does not appear to own execution.
19. As a user of `to-prd`, I want PRD creation to stop assuming GitHub issues are always the destination, so that feature requirements can land in the backend that fits the project.
20. As a user of `to-plan`, I want the skill to produce durable local Markdown plan artifacts from a PRD, so that local planning can stay in repo files instead of GitHub issues.
21. As a user of engineering-planning skills, I want refactor and maintenance planning to use the same backend model, so that non-feature work is not second-class.
22. As a maintainer, I want the repo documentation to tell a consistent story about PRDs, plans, tickets, and execution, so that users can understand the model quickly.
23. As a maintainer, I want backend selection rules to be explicit and testable, so that the behavior remains predictable as the skills evolve.
24. As a maintainer, I want the Backlog.md integration to support parent/child and dependency-friendly ticket modeling, so that it can stand in for GitHub issue hierarchies where needed.
25. As a developer, I want to keep the option of using pure local planning with commits as the tickets, so that the lightest-weight workflow still exists.

## Implementation Decisions

- Support exactly three planning/work-tracking backends in v1: `github`, `backlog`, and `local`.
- Resolve backend choice using this precedence: explicit user instruction for the current run, then local private override, then checked-in project default.
- Keep execution out of the backend abstraction. Planning backends track work; pi sessions and custom scripts execute it.
- Use Backlog.md as the primary local-first GitHub issue replacement.
- In Backlog.md mode, recommend a hidden repo path such as `.backlog` that is gitignored and used as a normal local directory by default.
- Keep support for an optional symlinked hidden backlog root when a user wants stronger physical separation while preserving repo-root discovery.
- Preserve `to-prd` as the PRD entry point for feature work, but remove the assumption that its output must always be filed as a GitHub issue.
- Keep PRDs scoped to feature work and user-story definition.
- Allow refactors, bug fixes, and maintenance work to bypass PRDs and go directly to plan/ticket artifacts.
- Keep `to-plan` as the canonical bridge from a PRD to durable local Markdown plan artifacts.
- For single-slice work, create one executable artifact in the selected workflow instead of forcing a parent plan artifact.
- For multi-slice work, create a parent plan artifact plus child tickets/tasks or slice files as appropriate for the selected workflow.
- In Backlog.md mode, use Backlog.md-native structures for ticket tracking and related planning material, rather than treating Backlog.md as an orchestration engine.
- In local mode, keep the workflow file-based: a single Markdown plan for single-slice work, or a parent plan plus child slice files for multi-slice work.
- Keep GitHub-native governance skills explicitly GitHub-specific rather than forcing them through the portable backend abstraction.
- Update the repo narrative so it describes PRDs, plans, tickets, and execution as separate concerns.

## Testing Decisions

- Good tests should validate observable behavior, not internal implementation details. They should assert which backend was selected, what artifacts were produced, and how the chosen backend affects user-visible outputs.
- Test backend resolution precedence across checked-in defaults, local private overrides, and explicit per-run instructions.
- Test behavior for the three supported backends: `github`, `backlog`, and `local`.
- Test that planning skills no longer assume execution is owned by the tracking backend.
- Test single-slice versus multi-slice artifact generation rules.
- Test that Backlog.md mode produces outputs that align with Backlog.md-native task tracking rather than Taskplane-style execution artifacts.
- Test that local mode produces durable Markdown planning artifacts with clear parent/child relationships.
- Test that portable planning skills preserve consistent conceptual behavior across backends while emitting backend-appropriate artifacts.
- Test or verify the recommended hidden `.backlog` setup well enough that maintainers can trust the documented local-first pattern, and note the optional symlinked variant for stronger separation.

## Out of Scope

- Replacing pi execution flows with Backlog.md-native execution.
- Reintroducing Taskplane orchestration as the default model for this feature.
- Supporting hybrid backend combinations in project config in v1.
- Supporting additional backends beyond `github`, `backlog`, and `local` in v1.
- Designing a full generic workflow engine for autonomous execution.
- Requiring every engineering task to begin with a PRD.
- Forcing GitHub-native governance skills into a backend-agnostic model.

## Further Notes

- The most important correction in this PRD is that the repo needs an **issues replacement**, not a new execution runtime.
- Backlog.md appears to fit this goal well because it provides Markdown-native tickets, docs, dependencies, a board, and a browser, while letting execution remain outside the tool.
- The hidden `.backlog` approach is important because it preserves local discoverability while keeping backlog state out of normal git history. A symlinked external directory remains an optional stronger-isolation variant.
- This PRD supersedes the earlier Taskplane-first direction for this feature.
