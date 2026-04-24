/**
 * Git Guardrails — opencode plugin
 *
 * Blocks dangerous git commands before the `bash` tool runs. Patterns live in
 * `patterns.txt` next to this file so every harness shares one source of truth.
 *
 * Install: drop this file (and patterns.txt) into `.opencode/plugins/` in the
 * target repo (project-local) or `~/.config/opencode/plugins/` (global).
 * opencode auto-discovers every `.ts`/`.js` file in those directories.
 */

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import type { Plugin } from "@opencode-ai/plugin";

const here = dirname(fileURLToPath(import.meta.url));
const patternsFile = join(here, "patterns.txt");

const patterns: RegExp[] = readFileSync(patternsFile, "utf8")
	.split("\n")
	.map((line) => line.trim())
	.filter((line) => line.length > 0 && !line.startsWith("#"))
	.map((line) => new RegExp(line));

export const GitGuardrails: Plugin = async () => ({
	"tool.execute.before": async (input, output) => {
		if (input.tool !== "bash") return;

		const cmd: string = (output.args as { command?: string }).command ?? "";
		if (!cmd) return;

		for (const re of patterns) {
			if (re.test(cmd)) {
				throw new Error(
					`BLOCKED: '${cmd}' matches dangerous pattern '${re.source}'. The user has prevented you from doing this.`,
				);
			}
		}
	},
});

export default GitGuardrails;
