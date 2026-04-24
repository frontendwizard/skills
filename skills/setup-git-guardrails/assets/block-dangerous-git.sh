#!/usr/bin/env bash
# Harness-agnostic dangerous-git blocker.
#
# Modes:
#   1. Claude Code PreToolUse hook: JSON on stdin, reads .tool_input.command (requires jq).
#   2. Direct:                      --command "<cmd>" (no jq needed).
#
# Blocked patterns live in patterns.txt next to this script, or at the path
# passed via --patterns.
#
# Exit codes:
#   0 — allow (no match)
#   2 — block (a pattern matched; message printed to stderr)
#   1 — internal error (missing jq in stdin mode, missing patterns file)

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
patterns_file="$script_dir/patterns.txt"
cmd=""

while [ $# -gt 0 ]; do
  case "$1" in
    --command) cmd="$2"; shift 2 ;;
    --patterns) patterns_file="$2"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$cmd" ]; then
  # Stdin mode: expect Claude Code PreToolUse JSON payload.
  if ! command -v jq >/dev/null 2>&1; then
    echo "error: jq is required for stdin JSON mode (install jq, or pass --command)" >&2
    exit 1
  fi
  input="$(cat)"
  cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
fi

# Nothing to check → allow.
if [ -z "$cmd" ]; then
  exit 0
fi

if [ ! -f "$patterns_file" ]; then
  echo "error: patterns file not found at $patterns_file" >&2
  exit 1
fi

while IFS= read -r pattern || [ -n "$pattern" ]; do
  case "$pattern" in
    ''|\#*) continue ;;
  esac
  if echo "$cmd" | grep -qE "$pattern"; then
    echo "BLOCKED: '$cmd' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done < "$patterns_file"

exit 0
