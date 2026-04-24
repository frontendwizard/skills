---
name: setup-git-guardrails
description: Install a harness-agnostic guardrail that blocks dangerous git commands (push, reset --hard, clean -fd, branch -D, checkout ., restore ., push --force) before the agent executes them. Supports Claude Code, pi, and opencode from one shared pattern list. Use when the user wants to prevent destructive git operations, add git safety hooks, or block git push / reset in any combination of these harnesses.
disable-model-invocation: true
---

# Setup Git Guardrails

Sets up a pre-tool-call guardrail that intercepts and blocks dangerous git commands before the agent executes them. One pattern list, one block script, three harness adapters — Claude Code, pi, opencode.

## What gets blocked

See [assets/patterns.txt](assets/patterns.txt). Default list:

- `git push` (all variants, including `--force` / `push --force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

When a command matches, the agent sees a stderr message explaining that the user has blocked it.

## Architecture

One source of truth, three adapters — all shipped in `assets/`:

| File | Role |
| --- | --- |
| `patterns.txt` | Extended regex per line. Blank lines and `#` comments ignored. |
| `block-dangerous-git.sh` | Bash blocker. Claude Code hook *and* direct CLI (`--command "<cmd>"`). |
| `pi-guardrails.ts` | pi extension. Subscribes to `tool_call` for `bash` and returns `{ block: true }`. |
| `opencode-guardrails.ts` | opencode plugin. Hooks `tool.execute.before` on `bash` and throws. |

The two TS adapters read `patterns.txt` from their own directory, so you must install the adapter file **and** `patterns.txt` side-by-side.

## Workflow

Run the steps interactively. Confirm with the user between irreversible actions.

### 1. Ask scope and harnesses

Ask two things:

1. **Scope** — project-local (the repo) or global (the user's home config)?
2. **Harnesses** — which of { Claude Code, pi, opencode } to install for. Multiple is fine.

Default install paths:

| Harness | Project scope | Global scope |
| --- | --- | --- |
| Claude Code | `.claude/hooks/` | `~/.claude/hooks/` |
| pi | `.pi/extensions/` | `~/.pi/agent/extensions/` |
| opencode | `.opencode/plugins/` | `~/.config/opencode/plugins/` |

### 2. Copy shared patterns file

For every chosen harness, copy `assets/patterns.txt` into the same directory where that harness's adapter will live. The TS adapters resolve `patterns.txt` relative to themselves, and the bash script does the same unless `--patterns` is passed.

If the user already has a different `patterns.txt` at the destination, ask before overwriting.

### 3. Install the chosen adapters

For each selected harness, copy the adapter file next to `patterns.txt`:

- **Claude Code** → `block-dangerous-git.sh`, `chmod +x`, then add the `PreToolUse` hook entry from [REFERENCE.md](REFERENCE.md) to `.claude/settings.json` (project) or `~/.claude/settings.json` (global). Merge into any existing `hooks.PreToolUse` array — do not overwrite other settings.
- **pi** → `pi-guardrails.ts`. Project-local location is auto-discovered, no settings edit needed. Global location likewise.
- **opencode** → `opencode-guardrails.ts`. Auto-discovered in both project and global plugin directories. No settings edit needed.

Require `jq` to be on PATH only for Claude Code (stdin JSON mode).

### 4. Offer to customise the pattern list

Ask whether the user wants to add, remove, or tighten any patterns. Edit the `patterns.txt` copy at each install location. Keep every harness in sync — if they pick multiple, write the same file to each location.

Do **not** edit the skill's source `assets/patterns.txt`; edits belong in the installed copies so re-running the skill does not resurrect deleted patterns. Mention this to the user.

### 5. Verify

Run a per-harness smoke test:

**Claude Code**

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | <path>/block-dangerous-git.sh
echo "exit=$?"
```

Expect `BLOCKED: …` on stderr and `exit=2`.

**pi**

```bash
<path>/block-dangerous-git.sh --command "git push origin main"
echo "exit=$?"
```

Same expectation. This also validates the pattern list the pi extension reads, since they share `patterns.txt`.

**opencode**

Same as pi — `--command` smoke test. For a true end-to-end check, start opencode in the target repo and ask it to `git push`; confirm the plugin throws.

### 6. Report

Print:

- Harnesses wired (count + list)
- Files copied and into which directories
- Settings file(s) edited (Claude Code only) and a short diff summary
- Next steps the user should take (install `jq` if Claude Code was chosen and it is missing; restart the harness if it is already running so it picks up the new plugin/extension)

## Rules

- Never commit. Leave the diff for the user to review.
- Never overwrite an existing `patterns.txt`, adapter, or settings section without asking.
- Idempotent on re-run: detect an existing Claude Code hook entry by its script path and skip re-inserting; overwrite adapter files only after confirmation; preserve any local edits the user made to an installed `patterns.txt` (show the diff and ask).
- If a chosen harness is not installed on the user's machine, ask whether to proceed anyway (install-for-later) or skip.
- Keep the pattern list in `patterns.txt` the single source of truth across all three harnesses. If the user wants harness-specific exceptions, document the divergence explicitly and record it in `REFERENCE.md`.
