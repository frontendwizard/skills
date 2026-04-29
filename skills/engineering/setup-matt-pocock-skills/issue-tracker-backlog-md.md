# Issue tracker: Backlog.md

Issues and PRDs for this repo live as Backlog.md tasks in the repo. Use the `backlog` CLI for all operations.

## Conventions

- **Create an issue**: `backlog task create "$TITLE" --description "$BODY" --plain`. Use shell variables or heredocs for multi-line descriptions.
- **Create a PRD**: Backlog.md does not need a separate PRD primitive. Create a task labelled `prd` and put the PRD body in the description: `backlog task create "$TITLE" --description "$BODY" --labels prd --plain`. If appropriate, add the triage label afterwards with `backlog task edit "$ID" --add-label "needs-triage" --plain`.
- **Create child implementation issues**: use Backlog.md parent tasks for PRD-to-implementation breakdowns: `backlog task create "$TITLE" --description "$BODY" --parent "$PARENT_ID" --plain`.
- **Represent blockers**: use dependencies when creating or editing a task: `backlog task create "$TITLE" --description "$BODY" --depends-on "$BLOCKER_IDS" --plain` or `backlog task edit "$ID" --depends-on "$BLOCKER_IDS" --plain`. `$BLOCKER_IDS` may be comma-separated or repeated according to the CLI help.
- **Read an issue**: `backlog task view "$ID" --plain`.
- **List issues**: `backlog task list --plain`, `backlog task list --status "To Do" --plain`, or `backlog task list --parent "$PARENT_ID" --plain`.
- **Apply / remove triage labels**: `backlog task edit "$ID" --add-label "$LABEL" --plain` / `backlog task edit "$ID" --remove-label "$LABEL" --plain`.
- **Add comments or triage notes**: Backlog.md has no GitHub-style comment stream. Append AI triage notes and agent briefs to implementation notes with `backlog task edit "$ID" --append-notes "$BODY" --plain`. The `triage` skill's AI disclaimer must still be included at the top of appended notes.
- **Close an issue**: use the repo's completed status. Default: `backlog task edit "$ID" --status "Done" --plain`. If this repo uses a different done status, record it here during setup.

## When a skill says "publish to the issue tracker"

Create a Backlog.md task. For PRDs, add the `prd` label. For implementation issues created from a PRD, set the PRD task as the parent.

## When a skill says "fetch the relevant ticket"

Run `backlog task view "$ID" --plain`. Backlog.md task IDs are normally displayed by the CLI; use the ID exactly as shown.
