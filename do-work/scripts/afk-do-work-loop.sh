#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)
PROMPT_FILE="$REPO_ROOT/do-work/afk-loop-prompt.md"
RUNNER="$REPO_ROOT/do-work/scripts/run-afk-do-work-iteration.py"
WORKER_TITLE="pi-do-work-worker"
RECENT_COMMITS_COUNT="${PI_DO_WORK_LOOP_RECENT_COMMITS_COUNT:-10}"
PI_BIN="${PI_DO_WORK_LOOP_PI_BIN:-pi}"
DEFAULT_ITERATIONS=10
ACTIVE_WORKER_PANE=""

usage() {
  cat <<'EOF'
Usage: do-work/scripts/afk-do-work-loop.sh [iterations]

Runs fresh AFK /do-work iterations in a right-side tmux pane.

Arguments:
  iterations   Maximum iterations to run (default: 10)

Environment:
  PI_DO_WORK_LOOP_PI_BIN               Override the pi executable path
  PI_DO_WORK_LOOP_RECENT_COMMITS_COUNT Override how many recent commits are attached (default: 10)
EOF
}

quote_args() {
  local quoted=""
  local arg
  for arg in "$@"; do
    printf -v quoted '%s%q ' "$quoted" "$arg"
  done
  printf '%s' "${quoted% }"
}

pane_exists() {
  tmux list-panes -t "$1" >/dev/null 2>&1
}

pane_current_command() {
  tmux display-message -p -t "$1" '#{pane_current_command}'
}

pane_is_idle() {
  local command
  command=$(pane_current_command "$1")
  case "$command" in
    bash|zsh|sh|fish)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

find_worker_pane() {
  local pane_id pane_title
  while IFS=' ' read -r pane_id pane_title; do
    if [[ "$pane_title" == "$WORKER_TITLE" ]]; then
      printf '%s\n' "$pane_id"
      return 0
    fi
  done < <(tmux list-panes -F '#{pane_id} #{pane_title}')
  return 1
}

ensure_worker_pane() {
  local pane_id
  if pane_id=$(find_worker_pane); then
    tmux select-pane -t "$pane_id" -T "$WORKER_TITLE"
    printf '%s\n' "$pane_id"
    return 0
  fi

  pane_id=$(tmux split-window -h -P -F '#{pane_id}' -c "$REPO_ROOT")
  tmux select-pane -t "$pane_id" -T "$WORKER_TITLE"
  printf '%s\n' "$pane_id"
}

generate_recent_commits_file() {
  local output_file=$1

  {
    echo "# Recent commits"
    echo
    git -C "$REPO_ROOT" log --max-count "$RECENT_COMMITS_COUNT" \
      --date=short \
      --pretty=format:'- %h %ad %s'
    echo
  } >"$output_file"
}

on_interrupt() {
  if [[ -n "$ACTIVE_WORKER_PANE" ]] && pane_exists "$ACTIVE_WORKER_PANE" && ! pane_is_idle "$ACTIVE_WORKER_PANE"; then
    tmux send-keys -t "$ACTIVE_WORKER_PANE" C-c
  fi
  echo
  echo "Loop interrupted."
  exit 130
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

ITERATIONS="${1:-$DEFAULT_ITERATIONS}"
if ! [[ "$ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Iterations must be a positive integer." >&2
  exit 1
fi

if [[ -z "${TMUX:-}" ]]; then
  echo "This loop must be started inside tmux." >&2
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required but was not found." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required but was not found." >&2
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

if [[ ! -x "$RUNNER" ]]; then
  echo "Worker runner is not executable: $RUNNER" >&2
  exit 1
fi

trap on_interrupt INT

LOOP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/pi-do-work-loop.XXXXXX")
WORKER_PANE=$(ensure_worker_pane)
ACTIVE_WORKER_PANE="$WORKER_PANE"

echo "AFK /do-work loop started."
echo "Worker pane: $WORKER_PANE"
echo "Loop data: $LOOP_DIR"

for ((iteration = 1; iteration <= ITERATIONS; iteration++)); do
  if ! pane_exists "$WORKER_PANE"; then
    echo "Worker pane was closed. Stopping."
    exit 1
  fi

  if ! pane_is_idle "$WORKER_PANE"; then
    echo "Worker pane is busy. Stopping."
    exit 1
  fi

  iteration_dir="$LOOP_DIR/iteration-$iteration"
  mkdir -p "$iteration_dir"

  recent_commits_file="$iteration_dir/recent-commits.md"
  log_file="$iteration_dir/worker.log"
  status_file="$iteration_dir/status"
  done_file="$iteration_dir/done"

  generate_recent_commits_file "$recent_commits_file"

  runner_command=$(quote_args \
    "$RUNNER" \
    --prompt-file "$PROMPT_FILE" \
    --recent-commits-file "$recent_commits_file" \
    --log-file "$log_file" \
    --pi-bin "$PI_BIN")

  printf -v worker_shell_command 'cd %q && %s; worker_exit_code=$?; printf "%%s\n" "$worker_exit_code" > %q; touch %q' \
    "$REPO_ROOT" \
    "$runner_command" \
    "$status_file" \
    "$done_file"

  echo "Starting iteration $iteration/$ITERATIONS..."
  tmux send-keys -t "$WORKER_PANE" C-c
  tmux send-keys -t "$WORKER_PANE" "$worker_shell_command" C-m

  while [[ ! -f "$done_file" ]]; do
    if ! pane_exists "$WORKER_PANE"; then
      echo "Worker pane was closed. Stopping."
      exit 1
    fi
    sleep 1
  done

  status=$(<"$status_file")
  if [[ "$status" != "0" ]]; then
    echo "Worker iteration $iteration exited with status $status. Stopping."
    exit "$status"
  fi

  if grep -Fq '<promise>NO MORE TASKS</promise>' "$log_file"; then
    echo "Worker reported no more tasks. Stopping."
    exit 0
  fi

  if grep -Fq '<promise>BLOCKED</promise>' "$log_file"; then
    echo "Worker reported blocked. Stopping."
    exit 0
  fi

done

echo "Iteration limit reached ($ITERATIONS)."
