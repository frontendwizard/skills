#!/usr/bin/env bash
# Default path: thin wrapper around `pi install -l git:github.com/frontendwizard/skills`.
# Legacy path (--legacy-copy): copy individual skill directories into
# <target>/.agents/skills/ for repos that cannot depend on a pi package.
#
# Usage:
#   scripts/install.sh [--source <spec>] [--global]
#   scripts/install.sh --legacy-copy [--force] [--target <dir>] <skill> [<skill> ...]
#
# Default flags:
#   --source git:github.com/frontendwizard/skills
#   --global     off (project install via `pi install -l`)
#
# Legacy flags:
#   --legacy-copy      enable legacy per-skill copy mode
#   --force            overwrite existing skill dirs
#   --target <dir>     target repo root (defaults to $(pwd))

set -euo pipefail

mode="pi-install"
source_spec="git:github.com/frontendwizard/skills"
global=0
force=0
target="$(pwd)"
skills=()

while [ $# -gt 0 ]; do
  case "$1" in
    --legacy-copy) mode="legacy-copy"; shift ;;
    --source) source_spec="$2"; shift 2 ;;
    --global) global=1; shift ;;
    --force) force=1; shift ;;
    --target) target="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    --) shift; skills+=("$@"); break ;;
    -*) echo "unknown flag: $1" >&2; exit 2 ;;
    *) skills+=("$1"); shift ;;
  esac
done

if [ "$mode" = "pi-install" ]; then
  if ! command -v pi >/dev/null 2>&1; then
    echo "error: pi CLI not found on PATH. Install pi or re-run with --legacy-copy." >&2
    exit 1
  fi
  if [ $global -eq 1 ]; then
    echo "+ pi install $source_spec"
    pi install "$source_spec"
  else
    echo "+ pi install -l $source_spec"
    pi install -l "$source_spec"
  fi
  echo "done. Verify with: pi list"
  exit 0
fi

# --- legacy copy mode ---

if [ ${#skills[@]} -eq 0 ]; then
  echo "no skills specified for --legacy-copy" >&2
  exit 2
fi

# Resolve the skills source root: this script lives at
#   <repo>/skills/setup-project/scripts/install.sh
# so individual skills live under <repo>/skills/<name>.
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
