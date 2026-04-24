#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)
PROMPT_FILE="$REPO_ROOT/do-work/afk-loop-prompt.md"
WORKER_TITLE="pi-do-work-worker"
WORKER_MARKER_OPTION="@pi_do_work_worker"
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
  local pane_id marker
  while IFS=' ' read -r pane_id marker; do
    if [[ "$marker" == "1" ]]; then
      printf '%s\n' "$pane_id"
      return 0
    fi
  done < <(tmux list-panes -F "#{pane_id} #{${WORKER_MARKER_OPTION}}")
  return 1
}

mark_worker_pane() {
  local pane_id=$1
  tmux set-option -pt "$pane_id" "$WORKER_MARKER_OPTION" 1 >/dev/null
  tmux select-pane -t "$pane_id" -T "$WORKER_TITLE"
}

ensure_worker_pane() {
  local pane_id
  if pane_id=$(find_worker_pane); then
    mark_worker_pane "$pane_id"
    printf '%s\n' "$pane_id"
    return 0
  fi

  pane_id=$(tmux split-window -h -P -F '#{pane_id}' -c "$REPO_ROOT")
  mark_worker_pane "$pane_id"
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

start_pane_logging() {
  local pane_id=$1
  local log_file=$2
  local pipe_command

  tmux pipe-pane -t "$pane_id"
  printf -v pipe_command 'cat > %q' "$log_file"
  tmux pipe-pane -t "$pane_id" "$pipe_command"
}

stop_pane_logging() {
  local pane_id=$1
  if pane_exists "$pane_id"; then
    tmux pipe-pane -t "$pane_id"
  fi
}

build_pi_command() {
  local recent_commits_file=$1
  local session_file=$2
  local prompt_arg="@$PROMPT_FILE"
  local recent_arg="@$recent_commits_file"

  quote_args "$PI_BIN" --session "$session_file" "$prompt_arg" "$recent_arg"
}

get_iteration_state() {
  local session_file=$1

  python3 - "$session_file" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
if not path.exists():
    print("pending")
    raise SystemExit(0)

last_assistant = None
with path.open(encoding="utf-8") as handle:
    for line in handle:
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
        if entry.get("type") != "message":
            continue
        message = entry.get("message") or {}
        if message.get("role") == "assistant":
            last_assistant = message

if not last_assistant or last_assistant.get("stopReason") == "toolUse":
    print("pending")
    raise SystemExit(0)

text = "".join(
    block.get("text", "")
    for block in (last_assistant.get("content") or [])
    if block.get("type") == "text"
)

if "<promise>NO MORE TASKS</promise>" in text:
    print("no_more")
elif "<promise>BLOCKED</promise>" in text:
    print("blocked")
else:
    print("complete")
PY
}

exit_worker_pane() {
  local pane_id=$1
  if pane_exists "$pane_id" && ! pane_is_idle "$pane_id"; then
    tmux send-keys -t "$pane_id" C-c C-c
  fi
}

wait_for_done_file() {
  local pane_id=$1
  local done_file=$2

  while [[ ! -f "$done_file" ]]; do
    if ! pane_exists "$pane_id"; then
      echo "Worker pane was closed. Stopping."
      exit 1
    fi
    sleep 1
  done
}

on_interrupt() {
  if [[ -n "$ACTIVE_WORKER_PANE" ]] && pane_exists "$ACTIVE_WORKER_PANE"; then
    stop_pane_logging "$ACTIVE_WORKER_PANE"
    exit_worker_pane "$ACTIVE_WORKER_PANE"
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
  session_file="$iteration_dir/session.jsonl"
  log_file="$iteration_dir/worker.log"
  status_file="$iteration_dir/status"
  done_file="$iteration_dir/done"

  generate_recent_commits_file "$recent_commits_file"
  pi_command=$(build_pi_command "$recent_commits_file" "$session_file")

  printf -v worker_shell_command 'cd %q && clear && printf "AFK /do-work iteration %s/%s\n\n" && %s; worker_exit_code=$?; printf "%%s\n" "$worker_exit_code" > %q; touch %q' \
    "$REPO_ROOT" \
    "$iteration" \
    "$ITERATIONS" \
    "$pi_command" \
    "$status_file" \
    "$done_file"

  start_pane_logging "$WORKER_PANE" "$log_file"

  echo "Starting iteration $iteration/$ITERATIONS..."
  tmux send-keys -t "$WORKER_PANE" C-c
  tmux send-keys -t "$WORKER_PANE" "$worker_shell_command" C-m

  iteration_state="pending"
  while true; do
    if ! pane_exists "$WORKER_PANE"; then
      echo "Worker pane was closed. Stopping."
      exit 1
    fi

    if [[ -f "$done_file" ]]; then
      break
    fi

    iteration_state=$(get_iteration_state "$session_file")
    if [[ "$iteration_state" != "pending" ]]; then
      break
    fi

    sleep 1
  done

  if [[ "$iteration_state" != "pending" ]]; then
    exit_worker_pane "$WORKER_PANE"
  fi

  wait_for_done_file "$WORKER_PANE" "$done_file"
  stop_pane_logging "$WORKER_PANE"

  status=$(<"$status_file")
  if [[ "$status" != "0" ]]; then
    echo "Worker iteration $iteration exited with status $status. Stopping."
    exit "$status"
  fi

  iteration_state=$(get_iteration_state "$session_file")
  if [[ "$iteration_state" == "no_more" ]]; then
    echo "Worker reported no more tasks. Stopping."
    exit 0
  fi

  if [[ "$iteration_state" == "blocked" ]]; then
    echo "Worker reported blocked. Stopping."
    exit 0
  fi
done

echo "Iteration limit reached ($ITERATIONS)."
