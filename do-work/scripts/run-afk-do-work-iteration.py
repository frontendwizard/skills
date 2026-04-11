#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any


class Renderer:
    def __init__(self, log_path: Path) -> None:
        self.log_handle = log_path.open("w", encoding="utf-8")
        self.at_line_start = True

    def close(self) -> None:
        self.ensure_newline()
        self.log_handle.close()

    def ensure_newline(self) -> None:
        if not self.at_line_start:
            self.write("\n")

    def write(self, text: str) -> None:
        sys.stdout.write(text)
        sys.stdout.flush()
        self.log_handle.write(text)
        self.log_handle.flush()
        self.at_line_start = text.endswith("\n")

    def line(self, text: str = "") -> None:
        self.ensure_newline()
        self.write(f"{text}\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run one AFK /do-work iteration through pi RPC mode.")
    parser.add_argument("--prompt-file", required=True)
    parser.add_argument("--recent-commits-file", required=True)
    parser.add_argument("--log-file", required=True)
    parser.add_argument("--pi-bin", default="pi")
    return parser.parse_args()


def load_attached_message(path: Path) -> str:
    return f"[Attached file: {path.name}]\n{path.read_text(encoding='utf-8').rstrip()}"


def build_message(prompt_file: Path, recent_commits_file: Path) -> str:
    return "\n\n".join(
        [
            load_attached_message(prompt_file),
            load_attached_message(recent_commits_file),
        ]
    ) + "\n"


def assistant_usage_line(message: dict[str, Any]) -> str | None:
    usage = message.get("usage") or {}
    total = usage.get("totalTokens")
    if total in (None, 0):
        return None
    input_tokens = usage.get("input", 0)
    output_tokens = usage.get("output", 0)
    cache_read = usage.get("cacheRead", 0)
    cache_write = usage.get("cacheWrite", 0)
    return (
        "[usage] "
        f"input={input_tokens} output={output_tokens} "
        f"cache-read={cache_read} cache-write={cache_write} total={total}"
    )


def summarize_tool_call(tool_name: str, args: dict[str, Any]) -> str:
    if tool_name == "bash" and isinstance(args.get("command"), str):
        return args["command"]
    if tool_name == "read" and isinstance(args.get("path"), str):
        return args["path"]
    if tool_name in {"edit", "write"} and isinstance(args.get("path"), str):
        return args["path"]
    return json.dumps(args, ensure_ascii=False)


def render_event(renderer: Renderer, event: dict[str, Any]) -> bool:
    event_type = event.get("type")

    if event_type == "message_end":
        message = event.get("message") or {}
        if message.get("role") == "assistant":
            content = message.get("content") or []
            if any(item.get("type") == "thinking" for item in content):
                renderer.line("[thinking]")
            usage_line = assistant_usage_line(message)
            if usage_line:
                renderer.line(usage_line)
        return False

    if event_type == "message_update":
        assistant_event = event.get("assistantMessageEvent") or {}
        if assistant_event.get("type") == "text_delta":
            delta = assistant_event.get("delta") or ""
            if delta:
                renderer.write(delta)
        return False

    if event_type == "tool_execution_start":
        tool_name = event.get("toolName", "tool")
        args = event.get("args") or {}
        renderer.line(f"→ {tool_name}: {summarize_tool_call(tool_name, args)}")
        return False

    if event_type == "tool_execution_end":
        tool_name = event.get("toolName", "tool")
        result = event.get("result") or {}
        content = result.get("content") or []
        text_parts = [item.get("text", "") for item in content if item.get("type") == "text"]
        summary = "".join(text_parts).strip()
        if summary:
            renderer.line(f"↳ {summary}")
        elif event.get("isError"):
            renderer.line(f"↳ {tool_name} failed")
        return False

    if event_type == "extension_ui_request":
        method = event.get("method", "unknown")
        renderer.line(f"[ui-request] {method}")
        return False

    if event_type == "response" and event.get("success") is False:
        renderer.line(f"[error] {event.get('command', 'unknown')}: {event.get('error', 'unknown error')}")
        return False

    if event_type == "agent_end":
        return True

    return False


def main() -> int:
    args = parse_args()
    prompt_file = Path(args.prompt_file)
    recent_commits_file = Path(args.recent_commits_file)
    log_file = Path(args.log_file)
    log_file.parent.mkdir(parents=True, exist_ok=True)

    renderer = Renderer(log_file)
    process = subprocess.Popen(
        [args.pi_bin, "--mode", "rpc", "--no-session"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    assert process.stdin is not None
    assert process.stdout is not None

    prompt_message = build_message(prompt_file, recent_commits_file)
    process.stdin.write(json.dumps({"id": "prompt-1", "type": "prompt", "message": prompt_message}) + "\n")
    process.stdin.flush()

    saw_agent_end = False
    for raw_line in process.stdout:
        try:
            event = json.loads(raw_line)
        except json.JSONDecodeError:
            renderer.write(raw_line)
            continue

        if render_event(renderer, event):
            saw_agent_end = True
            break

    if process.stdin and not process.stdin.closed:
        process.stdin.close()

    remainder = process.stdout.read()
    if remainder:
        renderer.write(remainder)

    return_code = process.wait()

    if return_code != 0:
        renderer.close()
        return return_code
    if not saw_agent_end:
        renderer.line("[error] pi session ended before agent_end")
        renderer.close()
        return 1

    renderer.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
