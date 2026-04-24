#!/usr/bin/env bash
# Install a bundle of skills into <pwd>/.agents/skills/ by copying them from
# the skills-repo clone this script lives in.
#
# Usage:
#   setup-project/scripts/install.sh [--force] [--target <dir>] <skill> [<skill> ...]
#
# Defaults:
#   --target  $(pwd)
#   --force   false (refuses to overwrite existing skill dirs)
#
# The script only copies files. It does NOT touch .gitignore, .skills/, or
# AGENTS.md — those steps live in SKILL.md so the agent can tailor them.

set -euo pipefail

force=0
target="$(pwd)"
skills=()

while [ $# -gt 0 ]; do
  case "$1" in
    --force) force=1; shift ;;
    --target) target="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    --) shift; skills+=("$@"); break ;;
    -*) echo "unknown flag: $1" >&2; exit 2 ;;
    *) skills+=("$1"); shift ;;
  esac
done

if [ ${#skills[@]} -eq 0 ]; then
  echo "no skills specified" >&2
  exit 2
fi

# Resolve the skills repo root: the directory two levels up from this script.
script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"

dest_root="$target/.agents/skills"
mkdir -p "$dest_root"

installed=()
skipped=()

for name in "${skills[@]}"; do
  src="$repo_root/$name"
  dst="$dest_root/$name"

  if [ ! -d "$src" ]; then
    echo "skip: '$name' not found in $repo_root" >&2
    skipped+=("$name (missing in source)")
    continue
  fi

  if [ -e "$dst" ] && [ $force -eq 0 ]; then
    skipped+=("$name (already installed; pass --force to overwrite)")
    continue
  fi

  rm -rf "$dst"
  cp -R "$src" "$dst"
  installed+=("$name")
done

echo "installed (${#installed[@]}): ${installed[*]:-<none>}"
if [ ${#skipped[@]} -gt 0 ]; then
  echo "skipped (${#skipped[@]}):"
  for s in "${skipped[@]}"; do echo "  - $s"; done
fi
echo "target: $dest_root"
