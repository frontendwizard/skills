#!/usr/bin/env bash
# Resolve the active task backend for the current repo.
# Precedence:
#   1. $SKILLS_TASKS_BACKEND env var (explicit per-run override)
#   2. .skills/config.local.toml  (gitignored per-user override)
#   3. .skills/config.toml         (committed project default)
# Prints one of: github | backlog-md | dex | local
# Exits 1 with a message if nothing resolves.

set -euo pipefail

extract() {
  # naive TOML extractor for `[tasks]\n... backend = "value"` under [tasks] section
  local file="$1"
  [ -f "$file" ] || return 1
  awk '
    /^\[tasks\][[:space:]]*$/ { in_tasks = 1; next }
    /^\[/ { in_tasks = 0 }
    in_tasks && /^[[:space:]]*backend[[:space:]]*=/ {
      sub(/^[^=]*=[[:space:]]*/, "")
      sub(/[[:space:]]*#.*$/, "")
      gsub(/^["'"'"']|["'"'"'][[:space:]]*$/, "")
      gsub(/[[:space:]]+$/, "")
      print
      exit
    }
  ' "$file"
}

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [ -n "${SKILLS_TASKS_BACKEND:-}" ]; then
  echo "$SKILLS_TASKS_BACKEND"
  exit 0
fi

for f in "$root/.skills/config.local.toml" "$root/.skills/config.toml"; do
  if [ -f "$f" ]; then
    val="$(extract "$f" || true)"
    if [ -n "$val" ]; then
      case "$val" in
        github|backlog-md|dex|local) echo "$val"; exit 0 ;;
        *) echo "unknown backend '$val' in $f" >&2; exit 1 ;;
      esac
    fi
  fi
done

echo "no task backend configured. create .skills/config.toml with [tasks] backend = \"...\"" >&2
exit 1
