# Plan: Backlog.md Issue Tracker Support

## Goal

Add Backlog.md as a first-class issue tracker option in Matt Pocock's upstream-style skills setup, without reintroducing the old `task-backend` abstraction.

After this change, a user running `/setup-matt-pocock-skills` can choose **Backlog.md**, and the setup skill writes `docs/agents/issue-tracker.md` with enough concrete `backlog` CLI guidance for these skills to work:

- `to-prd`
- `to-issues`
- `triage`

## Branch

Use a dedicated branch for implementation and testing:

```bash
git switch -c add-backlog-md-issue-tracker-support
```

## Design constraints

- Follow the current upstream abstraction: issue tracker behavior is configured through `docs/agents/issue-tracker.md`, not through a code adapter.
- Do not bring back `.skills/config.toml`, `task-backend`, or backend resolver scripts.
- Treat Backlog.md tasks as the issue tracker primitive.
- Use Backlog.md labels for triage roles.
- Use implementation notes as the comment stream, because Backlog.md has no GitHub-style comments.
- Keep the change small enough to be upstreamable.

## Files to change

### Add

```text
skills/engineering/setup-matt-pocock-skills/issue-tracker-backlog-md.md
```

### Modify

```text
skills/engineering/setup-matt-pocock-skills/SKILL.md
README.md
```

## Implementation steps

### 1. Add the Backlog.md issue tracker template

Create `skills/engineering/setup-matt-pocock-skills/issue-tracker-backlog-md.md`.

The template should say that issues and PRDs live as Backlog.md tasks in the repo and that all operations use the `backlog` CLI.

Document these operations.

#### Create an issue

```bash
backlog task create "$TITLE" --description "$BODY" --plain
```

#### Create a PRD

Backlog.md does not need a separate PRD primitive. Create a task labelled `prd` and put the PRD body in the description:

```bash
backlog task create "$TITLE" --description "$BODY" --labels prd --plain
```

Then add the triage label if appropriate:

```bash
backlog task edit "$ID" --add-label "needs-triage" --plain
```

#### Create child implementation issues

Use Backlog.md parent tasks for PRD-to-implementation breakdowns:

```bash
backlog task create "$TITLE" --description "$BODY" --parent "$PARENT_ID" --plain
```

#### Represent blockers

Use dependencies:

```bash
backlog task create "$TITLE" --description "$BODY" --depends-on "$BLOCKER_IDS" --plain
backlog task edit "$ID" --depends-on "$BLOCKER_IDS" --plain
```

`$BLOCKER_IDS` may be comma-separated or repeated according to the CLI help.

#### Read an issue

```bash
backlog task view "$ID" --plain
```

#### List issues

```bash
backlog task list --plain
backlog task list --status "To Do" --plain
backlog task list --parent "$PARENT_ID" --plain
```

#### Apply and remove triage labels

```bash
backlog task edit "$ID" --add-label "$LABEL" --plain
backlog task edit "$ID" --remove-label "$LABEL" --plain
```

#### Add comments or triage notes

Backlog.md has no comment stream. Append AI triage notes and agent briefs to implementation notes:

```bash
backlog task edit "$ID" --append-notes "$BODY" --plain
```

The triage skill's AI disclaimer must still be included at the top of appended notes.

#### Close an issue

Use the repo's completed status. Default guidance:

```bash
backlog task edit "$ID" --status "Done" --plain
```

If the repo uses a different done status, record that during setup in `docs/agents/issue-tracker.md`.

## 2. Update setup skill copy

Modify `skills/engineering/setup-matt-pocock-skills/SKILL.md`.

### Description/front matter

Change the issue tracker list from GitHub/local-only language to:

```text
GitHub, GitLab, Backlog.md, dex, local markdown, or another issue tracker
```

If implementing Backlog.md alone first, mention Backlog.md in this branch and leave dex for the dex branch.

### Explore step

Add Backlog.md detection hints:

```markdown
- `.backlog/` — sign Backlog.md is already initialized
- `backlog task list --plain` — if `backlog` is installed and `.backlog/` exists
```

Do not run destructive or initializing commands during exploration.

### Section A choices

Add:

```markdown
- **Backlog.md** — issues live as Backlog.md tasks in this repo, managed with the `backlog` CLI
```

### Template list

Add:

```markdown
- [issue-tracker-backlog-md.md](./issue-tracker-backlog-md.md) — Backlog.md issue tracker
```

### Triage wording

Where the setup skill says “labels”, use wording that still fits Backlog.md:

```text
labels or equivalent issue-tracker metadata
```

Backlog.md does support labels, so no special metadata convention is needed beyond that.

## 3. Update README

Modify `README.md` quickstart copy so it no longer says only GitHub/Linear/local files.

Suggested wording:

```text
Ask you which issue tracker you want to use (GitHub, GitLab, Backlog.md, local files, or another tracker)
```

If the README reference section describes `setup-matt-pocock-skills`, update it to include Backlog.md.

## Manual test plan

Run these checks on the Backlog.md branch.

### Static checks

```bash
rg "GitHub, Linear|GitHub or local|GitHub/local" README.md skills/engineering/setup-matt-pocock-skills
rg "Backlog.md" README.md skills/engineering/setup-matt-pocock-skills
```

Expected:

- no stale GitHub/local-only setup copy
- Backlog.md appears in setup choices and template list

### CLI command sanity

```bash
backlog task create --help
backlog task edit --help
backlog task view --help
backlog task list --help
```

Expected:

- documented flags exist: `--description`, `--labels`, `--parent`, `--depends-on`, `--add-label`, `--remove-label`, `--append-notes`, `--status`, `--plain`

### End-to-end smoke test in a scratch repo

Use a temporary repo, not this repo:

```bash
TMP=$(mktemp -d)
cd "$TMP"
git init
backlog init test-project
```

Then simulate the generated issue tracker doc commands:

```bash
PRD_ID=$(backlog task create "PRD: Test Backlog support" --description "PRD body" --labels prd --plain | rg -o 'task-[0-9]+' | head -1)
backlog task edit "$PRD_ID" --add-label needs-triage --plain
TASK_ID=$(backlog task create "Implement slice 1" --description "Slice body" --parent "$PRD_ID" --plain | rg -o 'task-[0-9]+' | head -1)
backlog task edit "$TASK_ID" --append-notes $'> *This was generated by AI during triage.*\n\nAgent brief here.' --plain
backlog task view "$TASK_ID" --plain
backlog task edit "$TASK_ID" --status Done --plain
```

Expected:

- PRD task is created
- child task is linked to parent
- notes append successfully
- status update succeeds

## Acceptance criteria

- `/setup-matt-pocock-skills` offers Backlog.md as a first-class option.
- Setup writes a Backlog.md-specific `docs/agents/issue-tracker.md` from a seed template.
- `to-prd` has clear instructions for creating a PRD task.
- `to-issues` has clear instructions for child tasks and blockers.
- `triage` has clear instructions for labels, notes, and closing tasks.
- Existing GitHub, GitLab, and local markdown behavior remains unchanged.
- No old fork-only `task-backend` abstraction is reintroduced.

## Open questions

- Should the default completed status be `Done`, or should setup explicitly ask the user which Backlog.md status means closed?
- Should PRDs use only a `prd` label, or should the template recommend Backlog.md docs via `backlog doc` for long-form PRDs?
- Should Backlog.md task IDs be documented as `task-N` specifically, or should the template avoid relying on the textual format?
