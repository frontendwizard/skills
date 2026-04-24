# Backend recipe: local Markdown

No tracker. Artifacts are Markdown files under `[tasks.local].plans_dir` (default `plans/`). Commits act as the tickets.

File layout:

- PRDs (epics): `plans/prd-<slug>.md`
- Single-phase plans: `plans/<slug>.md`
- Multi-phase plans: `plans/<slug>.md` with one `## Phase N — <title>` section per phase
- Big phases: same file, nested `### Subtask` headings

## create_epic(title, body)

Write `plans/prd-<slug>.md` with `$BODY`. Return the file path as the id.

## create_task(title, body, parent_epic?)

- If `parent_epic` is set: append a `## <title>` section to the parent's file (parent id is the file path). Prepend `Parent: <parent_epic>` inside the section if it's not already obvious.
- If not: write `plans/<slug>.md` with `$BODY`.

Return `<path>#<anchor>` as the id.

## create_subtask(title, body, parent_task)

Append a `### <title>` section under the parent section in the parent file. Return `<path>#<anchor>` as the id.

## get(id)

Read the file (and section if the id contains `#<anchor>`).

## list_open(filter?)

`ls plans/` or `rg -l "$FILTER" plans/`. There's no status field; "open" = uncommitted or unticked.

## update(id, fields)

Edit the file in place. For status, use checkbox conventions in the file (`- [ ]` / `- [x]`).

## comment(id, body)

Append a dated note section to the file:

```md
### Note — YYYY-MM-DD

$BODY
```

## Notes

- Do NOT create noisy per-slice ticket files. Keep multi-phase work in a single plan file.
- Relationships are expressed by file structure and prose references, not metadata.
