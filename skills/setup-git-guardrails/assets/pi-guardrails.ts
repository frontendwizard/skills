/**
 * Git Guardrails — pi extension
 *
 * Blocks dangerous git commands before the `bash` tool runs. Patterns live in
 * `patterns.txt` next to this file so every harness shares one source of truth.
 *
 * Install: drop this file (and patterns.txt) into `.pi/extensions/` in the
 * target repo, or anywhere pointed to by an `extensions` entry in pi settings.
 */

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const here = dirname(fileURLToPath(import.meta.url));
const patternsFile = join(here, "patterns.txt");

const patterns: RegExp[] = readFileSync(patternsFile, "utf8")
	.split("\n")
	.map((line) => line.trim())
	.filter((line) => line.length > 0 && !line.startsWith("#"))
	.map((line) => new RegExp(line));

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const cmd = (event.input as { command?: string }).command ?? "";
		if (!cmd) return undefined;

		for (const re of patterns) {
			if (re.test(cmd)) {
				const reason = `BLOCKED: '${cmd}' matches dangerous pattern '${re.source}'. The user has prevented you from doing this.`;
				if (ctx.hasUI) {
					ctx.ui.notify(`git-guardrails blocked: ${re.source}`, "warning");
				}
				return { block: true, reason };
			}
		}

		return undefined;
	});
}
