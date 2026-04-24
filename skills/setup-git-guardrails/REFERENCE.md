# Setup Git Guardrails — reference

## Claude Code settings block

Merge into the target settings file. **Never overwrite** other keys; add the hook entry to the existing `hooks.PreToolUse` array if one exists.

### Project (`.claude/settings.json`)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

### Global (`~/.claude/settings.json`)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

## Default blocked patterns

Mirrors `assets/patterns.txt`. Extended regex syntax. Patterns match anywhere in the bash command string.

| Pattern | Intent |
| --- | --- |
| `git push` | Any push to any remote, including `--force`. |
| `git reset --hard` | Discards uncommitted work. |
| `git clean -f` / `git clean -fd` | Deletes untracked files / directories. |
| `git branch -D` | Force-deletes a branch, losing unmerged commits. |
| `git checkout \.` | Discards working-tree changes. |
| `git restore \.` | Same, modern syntax. |
| `push --force` / `reset --hard` | Catches the operation even when wrapped in shell aliases, subshells, or `&&` chains. |

### Customisation guidance

- **Add a pattern** — one extended regex per line. Escape literal dots (`\.`) and literal parens. Test with `grep -qE "<pattern>" <<< "<command>"`.
- **Whitelist a safe use** — prefer a more specific blocker instead. For example, replace `git push` with `git push (?!origin review/)` if your review workflow legitimately needs pushes to `review/*`. Validate the regex across all three harnesses (bash, pi RegExp, opencode RegExp) — they share JavaScript-compatible semantics in the TS adapters, but the bash adapter uses POSIX ERE. Keep patterns in the intersection.
- **Harness-specific exceptions** — if a harness must diverge (e.g. pi runs in an AFK loop that needs `git push`), record the divergence in this file, duplicate only the differing file in that harness's install location, and keep every other pattern identical.

## Regex dialect matrix

| Harness | Engine | Notes |
| --- | --- | --- |
| Claude Code (bash) | `grep -E` (POSIX ERE) | No lookahead/lookbehind. Use alternation. |
| pi (TS) | JavaScript `RegExp` | Full PCRE-lite. Lookahead/lookbehind OK. |
| opencode (TS) | JavaScript `RegExp` | Same as pi. |

Keep shared patterns in the intersection (POSIX ERE) unless you accept divergent copies.

## Smoke-test matrix

```bash
# Works across all harnesses — bash script with --command.
block-dangerous-git.sh --command "git push origin main"     ; echo $?   # 2
block-dangerous-git.sh --command "git status"               ; echo $?   # 0
block-dangerous-git.sh --command "git reset --hard HEAD~1"  ; echo $?   # 2

# Claude Code stdin mode (needs jq).
echo '{"tool_input":{"command":"git clean -fd"}}' | block-dangerous-git.sh ; echo $?   # 2
```

## Idempotency notes

When re-running the skill:

- Detect an existing Claude Code hook by its `command` string (ends with `block-dangerous-git.sh`). Do not insert a duplicate entry.
- Preserve user edits to an installed `patterns.txt`. Show a diff against the source `assets/patterns.txt` and ask before overwriting.
- pi and opencode adapter files can be overwritten wholesale after user confirmation, since they carry no user configuration — all state lives in `patterns.txt`.
