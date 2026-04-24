# Backend recipe: Backlog.md (MrLesk/Backlog.md)

Requires `backlog` CLI and `backlog init` already run. Task root from `[tasks.backlog-md].root` (default `.backlog`).

Backlog.md has no native "epic" concept. Epics are modeled as tasks with the `epic` label so children can reference them via `--parent`.

## create_epic(title, body)

```bash
backlog task create "$TITLE" --description "$BODY" --labels epic --plain
```

Returns a task id like `task-12`. That id is the `parent_epic` for child tasks.

Optional: if the caller is `to-prd` and wants a long-form PRD doc alongside, also run:

```bash
backlog doc create "$TITLE" --type prd
```

Then reference the doc path from the epic body.

## create_task(title, body, parent_epic?)

```bash
backlog task create "$TITLE" --description "$BODY" ${PARENT:+--parent "$PARENT"} --plain
```

## create_subtask(title, body, parent_task)

Same as `create_task` with `--parent "$PARENT_TASK"` required. Subtasks are just tasks whose parent is itself a task.

## get(id)

```bash
backlog task view "$ID" --plain
```

Parse stdout for title, status, parent, labels.

## list_open(filter?)

```bash
backlog task list --plain ${PARENT:+--parent "$PARENT"} ${STATUS:+--status "$STATUS"}
```

## update(id, fields)

- Status: `backlog task edit "$ID" --status "$S" --plain`
- Title: `backlog task edit "$ID" --title "$T" --plain`
- Description: `backlog task edit "$ID" --description "$B" --plain`
- Labels: `backlog task edit "$ID" --add-label "$L" --plain` / `--remove-label`
- Parent: `backlog task edit "$ID" --parent "$P" --plain`

## comment(id, body)

Backlog.md has no comment stream. Append to implementation notes:

```bash
backlog task edit "$ID" --append-notes "$BODY" --plain
```
