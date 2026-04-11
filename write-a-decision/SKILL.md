---
name: write-a-decision
description: Create durable ADR-style decision records and land them in the project's decision store. Use when user wants to record an architecture or technical decision, mentions ADRs or decision records, wants to capture tradeoffs, supersede an earlier decision, or link a durable decision to tasks, plans, docs, or issues.
---

Use this skill when a choice should remain discoverable after the current conversation. Do not use it for transient brainstorming or executable task planning.

1. Confirm that a durable decision record is warranted. Good triggers include:
- architecture or infrastructure choices
- cross-cutting technical policies
- product or process rules with lasting consequences
- reversing, rejecting, or superseding an earlier decision

If the user only needs implementation planning, route them to a planning or ticket skill instead.

2. Gather the minimum inputs:
- decision title
- decision status (`proposed`, `accepted`, `superseded`, `rejected`, or repo-specific equivalent)
- context or problem statement
- options considered
- chosen decision
- consequences and tradeoffs
- related artifacts such as tasks, plans, PRDs, docs, issues, and prior decisions

3. Explore the repo and referenced artifacts enough to verify terminology, current conventions, and durable links.

4. Resolve the output backend before writing the final artifact. Use this precedence order:
- explicit user instruction for the current run
- local private override in `.pi/planning.local.json`
- checked-in project default in `.pi/planning.json`

If the repo has shared planning conventions, follow them as the source of truth for backend behavior (for this repo, that file is `PLANNING.md`).

Supported backends are `github`, `backlog`, and `local`.

5. Land the decision in the backend-appropriate shape:
- `github`: create a GitHub-native decision artifact, usually an issue or ADR document, and link related issues or plans
- `backlog`: treat Backlog.md decisions as the ADR-equivalent. Prefer `backlog decision create "<title>"` when the CLI is available, then complete the generated file in `.backlog/decisions/`
- `local`: create a local Markdown decision record, usually under `decisions/` unless the repo already has a better established location

6. Decide whether this is a new decision, an update, or a superseding decision. Prefer preserving history by creating a new record that references the old one instead of silently overwriting prior rationale.

7. Use or preserve this structure:

<decision-template>
## Context
The problem, forces, constraints, and relevant background.

## Decision
The chosen option and the reasoning for choosing it.

## Consequences
Expected benefits, costs, risks, and follow-on work.

## Alternatives Considered (optional)
Rejected options and why they were not chosen.

## Related Artifacts (optional)
Links or identifiers for tasks, plans, PRDs, docs, issues, or prior decisions.

## Supersedes / Superseded By (optional)
References to earlier or later decision records.
</decision-template>

If the Backlog.md CLI generates frontmatter and `Context / Decision / Consequences`, preserve that structure and add only the extra sections you actually need.

8. Link the final decision to the relevant tasks, plans, PRDs, docs, issues, and earlier decisions using durable identifiers or paths.

9. Before finalizing, state which backend you resolved and why.
