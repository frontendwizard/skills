# Plan: Per-project planning backends for skills

> Source PRD: `plans/prd-support-per-project-planning-backends.md`

## Architectural decisions

Durable decisions that apply across all phases:

- **Supported backends**: v1 supports exactly `github`, `backlog`, and `local`.
- **Selection precedence**: explicit user instruction for the current run overrides local private config, which overrides the checked-in project default.
- **Concern split**: planning/work tracking and execution are separate concerns. Backends track work; pi sessions and custom scripts execute it.
- **Artifact model**: PRDs are for feature work; plans break implementation down; tickets/tasks are executable units of work.
- **Single vs multi-slice**: single-slice work can go straight to one ticket; multi-slice work needs a parent plan artifact plus child tickets/tasks in the selected backend.
- **Backlog.md mode**: Backlog.md is used as a GitHub issues replacement, not as an execution runtime.
- **Backlog storage model**: the recommended repo integration is a gitignored hidden `.backlog` path used as a normal local directory by default. A symlink to an external directory remains optional for stronger isolation.
- **Local mode**: multi-slice work creates a Markdown plan only; commits act as the tickets and no child ticket files are created.
- **GitHub-native boundary**: governance and maintainer workflows that are truly about GitHub stay GitHub-specific.
- **Repo default**: this repo should dogfood the Backlog.md workflow, with the backlog itself kept outside the repo history.

---

## Phase 1: Establish planning conventions and Backlog.md-first repo defaults

**Task ID**: `PB-001`

**User stories**: 1, 3, 4, 5, 6, 7, 14, 15, 16, 17, 18, 22, 23

### What to build

Create the shared planning conventions that all portable planning skills can follow. Define the supported backends, precedence rules, and the separation between tracking and execution. Update the repo narrative so a reader can understand how PRDs, plans, tickets, and execution relate. Document the recommended hidden gitignored `.backlog` setup for private local-first tracking, with symlinks as an optional stronger-isolation variant.

### Acceptance criteria

- [ ] The repo has one shared source of truth for planning conventions and backend selection rules.
- [ ] The docs clearly separate work tracking from execution.
- [ ] The docs explain the distinction between PRDs, plans, tickets, and execution.
- [ ] The docs describe the recommended gitignored hidden `.backlog` setup and mention the optional symlinked stronger-isolation variant.

---

## Phase 2: Make feature PRD creation backend-aware

**Task ID**: `PB-002`

**User stories**: 8, 10, 18, 19, 22, 23

### What to build

Update the feature PRD flow so `write-a-prd` no longer assumes GitHub issues are always the destination. The skill should preserve PRDs as the artifact for feature requirements while routing the output to the configured backend shape for GitHub, Backlog.md, or local workflows.

### Acceptance criteria

- [ ] `write-a-prd` clearly states that PRDs are for feature work.
- [ ] `write-a-prd` no longer assumes GitHub issues are the only valid output.
- [ ] The skill explains how PRDs should land in GitHub, Backlog.md-first, and local workflows.
- [ ] The resulting instructions do not force non-feature work through a PRD path.

---

## Phase 3: Make PRD-to-plan produce backend-appropriate plans and tickets

**Task ID**: `PB-003`

**User stories**: 12, 13, 20, 24, 25

### What to build

Update `prd-to-plan` so it can turn a PRD into the right implementation artifacts for each backend. Single-slice work should become a single ticket. Multi-slice work should create a parent plan in `plans/`, and in Backlog.md mode it should also create child Backlog.md tickets with the right parent/dependency-friendly structure.

### Acceptance criteria

- [ ] `prd-to-plan` defines different output behavior for single-slice and multi-slice work.
- [ ] Multi-slice Backlog.md output creates a parent plan plus child Backlog.md tickets.
- [ ] Local output keeps multi-slice work in a Markdown plan without noisy child ticket files.
- [ ] The parent/child relationship between a plan and its tickets is described in a durable way.

---

## Phase 4: Align engineering planning flows with the backend model

**Task ID**: `PB-004`

**User stories**: 8, 9, 11, 18, 21, 22

### What to build

Update non-PRD planning skills so refactors, bug-fix planning, and maintenance work can use the same backend model without pretending they are product PRDs. At the same time, make the GitHub-native boundary explicit for repo governance skills that should stay issue-focused.

### Acceptance criteria

- [ ] Engineering-planning skills no longer force GitHub issue output when the work is not GitHub-native.
- [ ] The skills explain when PRDs are unnecessary.
- [ ] GitHub-native maintainer workflows remain clearly marked as GitHub-specific.
- [ ] The repo catalog reflects the split between portable planning and GitHub-native governance.

---

## Phase 5: Set up Backlog.md integration and examples for this repo

**Task ID**: `PB-005`

**User stories**: 2, 3, 14, 15, 16, 17, 18, 22, 24

### What to build

Set up the repo to use Backlog.md in the recommended private local-first way. That includes the hidden `.backlog` integration pattern, gitignore guidance, and at least one concrete example that shows how a plan becomes tickets in Backlog.md while execution still happens in pi or a custom loop.

### Acceptance criteria

- [ ] The repo has a documented Backlog.md setup that keeps the backlog outside committed repo history.
- [ ] The `.backlog` integration pattern is clear and reproducible.
- [ ] At least one concrete Backlog.md-first example exists for this initiative.
- [ ] A maintainer can follow the docs and understand how to go from PRD to plan to Backlog.md tickets in this repo.

---

## Phase 6: Clean up naming, catalog copy, and stale Taskplane-first assumptions

**Task ID**: `PB-006`

**User stories**: 8, 18, 22, 23

### What to build

Remove or replace backend-coupled planning names and catalog copy that no longer fit the new model, and clean up any stale Taskplane-first framing left over from the earlier direction for this initiative.

### Acceptance criteria

- [ ] Backend-coupled planning naming that no longer matches the workflow is removed or replaced.
- [ ] The README and skill descriptions tell a consistent story about GitHub, Backlog.md, and local planning backends.
- [ ] Stale Taskplane-first assumptions for this initiative are removed from repo-facing docs and examples.
- [ ] A maintainer can read the repo and understand that Backlog.md is the preferred GitHub issue replacement here, while execution remains outside the tracking backend.
