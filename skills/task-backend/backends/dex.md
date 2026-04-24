# Backend recipe: dex (dex.rip)

Requires `dex` CLI and `dex init` already run. dex has no native "epic" concept — model epics as top-level tasks and tasks/subtasks as children via `--parent`.

## create_epic(title, body)

```bash
dex create "$TITLE" --description "$BODY" --json
```

Parse `id` from JSON. That id is the `parent_epic` for child tasks.

## create_task(title, body, parent_epic?)

```bash
dex create "$TITLE" --description "$BODY" ${PARENT:+--parent "$PARENT"} --json
```

## create_subtask(title, body, parent_task)

Same as `create_task` with `--parent "$PARENT_TASK"` required.

## get(id)

```bash
dex show "$ID" --json
```

## list_open(filter?)

```bash
dex list --json ${FILTER:+--query "$FILTER"}
```

## update(id, fields)

- Start: `dex start "$ID"`
- Complete: `dex complete "$ID" --result "$RESULT" ${COMMIT:+--commit "$COMMIT"}` (or `--no-commit`)
- Edit body/title: `dex edit "$ID" -n "$NOTE"`
- Link commit: `dex edit "$ID" --commit "$SHA"`

## comment(id, body)

dex has no comment stream. Append to description via `dex edit "$ID" -n "$BODY"`.

## Plan import shortcut

For planning skills producing a single plan file, prefer:

```bash
dex plan "$PLAN_FILE"
```

This creates the epic + tasks tree in one step.
