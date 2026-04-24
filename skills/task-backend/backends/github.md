# Backend recipe: GitHub Issues

Requires `gh` CLI authenticated. Repo auto-detected unless `[tasks.github].repo` is set in config; pass `--repo "$REPO"` when it is.

## create_epic(title, body)

```bash
gh issue create --title "$TITLE" --body "$BODY" --label epic
```

Returns the issue URL from stdout; the issue number is the last path segment.

## create_task(title, body, parent_epic?)

If `parent_epic` is set, prepend to body:

```
## Parent

#<parent_epic>
```

Then:

```bash
gh issue create --title "$TITLE" --body "$BODY"
```

## create_subtask(title, body, parent_task)

Same as `create_task` with `parent_task` in the `## Parent` header. Additionally add label `subtask` if the repo uses it.

## get(id)

```bash
gh issue view "$ID" --json number,title,body,state,url,labels
```

Parent is parsed from the `## Parent` header in the body.

## list_open(filter?)

```bash
gh issue list --state open --limit 100 ${FILTER:+--search "$FILTER"}
```

## update(id, fields)

- Status: `gh issue close "$ID"` or `gh issue reopen "$ID"`
- Labels: `gh issue edit "$ID" --add-label "$L"` / `--remove-label`
- Body: `gh issue edit "$ID" --body "$BODY"`
- Parent: re-edit body, replace `## Parent` header

## comment(id, body)

```bash
gh issue comment "$ID" --body "$BODY"
```
