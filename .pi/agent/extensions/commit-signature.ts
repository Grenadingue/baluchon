import { execFileSync } from "node:child_process";
import {
  isToolCallEventType,
  type ExtensionAPI,
  type ExtensionContext,
} from "@earendil-works/pi-coding-agent";

/** Matches a `git commit` invocation inside a shell command. */
const GIT_COMMIT = /(?:^|[\s;&|(`$])git\s+commit\b/;

/** Matches a quoted commit message: `-m "..."`, `-m '...'`, `--message="..."`, `--message '...'`. */
const MESSAGE_FLAG = /(?:-m|--message)(?:=|[\s])("(?:[^"\\]|\\.)*"|'[^']*')/;

/** Detects the signature block in a resolved commit message. */
const SIGNED = /co-authored-by\s*:/i;
const SIGNED_MODEL = /ai-model\s*:/i;

/** Co-authored-by identity injected per coding-agent harness. */
const HARNESS_IDENTITIES: Record<string, { name: string; email: string }> = {
  pi: { name: "Pi Coding Agent", email: "agent@pi.dev" },
  opencode: { name: "OpenCode Agent", email: "agent@opencode.ai" },
};

/** Canonical model host domain per model provider. */
const PROVIDER_DOMAINS: Record<string, string> = {
  anthropic: "anthropic.com",
  groq: "groq.com",
  mistral: "mistral.ai",
  ollama: "ollama.com",
  openai: "openai.com",
  openrouter: "openrouter.ai",
};

/**
 * Derives the friendly model name from a raw `<family>:<tag>` model id by
 * dropping the tag (size/quantization/context noise) and capitalizing the
 * family tokens: `qwen3.8-flash-next:125b-...` -> `Qwen3.8-Flash-Next`.
 */
export function friendlyModelName(modelId: string): string {
  const family = modelId.split(":")[0] ?? "";
  return family
    .split("-")
    .map((token) => token.charAt(0).toUpperCase() + token.slice(1))
    .filter(Boolean)
    .join("-");
}

function isSigned(message: string): boolean {
  return SIGNED.test(message) && SIGNED_MODEL.test(message);
}

/**
 * Appends the trailer block as a final paragraph inside the last quoted message
 * argument. Returns undefined when no statically resolvable quoted message exists.
 */
export function appendTrailers(command: string, trailers: string): string | undefined {
  const re = new RegExp(MESSAGE_FLAG.source, "g");
  let match: RegExpExecArray | null;
  let last: RegExpExecArray | null = null;
  while ((match = re.exec(command)) !== null) last = match;
  if (!last) return undefined;

  const raw = last[1];
  const quote = raw[0];
  const content = raw.slice(1, -1);
  // Guard: a dangling escape would swallow the closing quote.
  if (quote === '"' && /(?:^|[^\\])\\$/.test(content)) return undefined;
  // Only literal messages are statically resolvable (not "$MSG" style variables).
  if (content.includes("$") || content.includes("`")) return undefined;

  const signed = quote + content + "\n\n" + trailers + quote;
  const start = last.index + last[0].length - raw.length;
  return command.slice(0, start) + signed + command.slice(start + raw.length);
}

function harnessIdentity(): { name: string; email: string } | undefined {
  return HARNESS_IDENTITIES[process.env.AI_AGENT ?? ""];
}

function modelLabel(ctx: ExtensionContext): string | undefined {
  const modelId = ctx.model?.id ?? process.env.PI_MODEL;
  const provider = ctx.model?.provider ?? process.env.PI_PROVIDER;
  if (!modelId || !provider) return undefined;
  const domain = PROVIDER_DOMAINS[provider];
  if (!domain) return undefined;
  return `${friendlyModelName(modelId)} <${modelId}@${domain}>`;
}

function buildTrailers(ctx: ExtensionContext): string | undefined {
  const identity = harnessIdentity();
  const model = modelLabel(ctx);
  if (!identity || !model) return undefined;
  return [
    `Co-authored-by: ${identity.name} <${identity.email}>`,
    `AI-Model: ${model}`,
  ].join("\n");
}

/** Reads the current HEAD commit message (used to resolve `--amend --no-edit`). */
function headMessage(command: string): string | undefined {
  const cd = /(?:^|&&\s*|;\s*)cd\s+([^\s;&|]+)/.exec(command)?.[1];
  try {
    return execFileSync("git", ["log", "-1", "--format=%B", "HEAD"], {
      cwd: cd,
      encoding: "utf8",
    });
  } catch {
    return undefined;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return;
    const command = event.input.command;
    if (!GIT_COMMIT.test(command)) return;

    // Case A: the message is a statically resolvable literal -> detect the
    // existing block in its content and inject only when missing.
    const trailers = buildTrailers(ctx);
    const withTrailers = trailers ? appendTrailers(command, trailers) : undefined;
    const literal = MESSAGE_FLAG.exec(command);
    if (literal) {
      const content = literal[1].slice(1, -1);
      if (isSigned(content)) return; // already signed, leave it untouched
      if (withTrailers) {
        event.input.command = withTrailers;
        ctx.ui.notify("commit-signature: injected trailers into git commit", "info");
      } else {
        return {
          block: true,
          reason:
            "Unsigned 'git commit': the message could not be signed automatically; pass the full message literally to -m (see the 'commit-signature' skill).",
        };
      }
      return;
    }

    // Case B: messageless amend (`--amend --no-edit`, `-c`/`-C`) -> the message
    // is HEAD's; leave it untouched when already signed, block otherwise.
    if (/--amend|--no-edit|-c\b|-C\b/.test(command)) {
      const head = headMessage(command);
      if (head && isSigned(head)) return;
    }

    return {
      block: true,
      reason:
        "Unsigned 'git commit': no statically resolvable message; pass the full message literally to -m (see the 'commit-signature' skill).",
    };
  });
}
