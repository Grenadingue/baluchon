---
name: commit-signature
description: Sign agent-made git commits with a Co-authored-by trailer (harness agent identity) and an AI-Model trailer (friendly model name + raw model id at provider domain). Mandatory every time a git commit is created or amended by the agent.
---

# Commit signature

Every commit created by the agent must identify the agent and the model as
co-authors, through a trailer block at the end of the commit message.

## Trailer block

```text
Co-authored-by: Pi Coding Agent <agent@pi.dev>
AI-Model: Qwen3.8-Flash-Next <qwen3.8-flash-next:125b-a6b-q4_K_M-ctx_96k-optimized@ollama.com>
```

- `Co-authored-by` : the harness identity (name + email) for the coding agent.
- `AI-Model` : friendly model name, then the raw model id at the provider's
  canonical domain.

## Identities

Harness (`AI_AGENT`) → `Co-authored-by` identity:

| Harness    | Identity                                        |
| ---------- | ----------------------------------------------- |
| `pi`       | `Pi Coding Agent <agent@pi.dev>`                |
| `opencode` | `OpenCode Agent <agent@opencode.ai>`            |

Provider (`PI_PROVIDER`) → domain used in the `AI-Model` email:

| Provider   | Domain          |
| ---------- | --------------- |
| `ollama`   | `ollama.com`    |
| `openai`   | `openai.com`    |
| `anthropic`| `anthropic.com` |
| `groq`     | `groq.com`      |
| `mistral`  | `mistral.ai`    |
| `openrouter` | `openrouter.ai` |

Never invent an identity or a domain: if the harness or provider is not listed,
stop and ask the user instead of guessing.

## Friendly model name

Derived from the raw model id (`PI_MODEL`), shaped `<family>:<tag>`:

1. Drop the `:` and everything after it (the tag only carries parameter size,
   quantization and context noise);
2. split the family on `-`;
3. capitalize the first letter of each token and join them back with `-`.

Example: `qwen3.8-flash-next:125b-a6b-q4_K_M-ctx_96k-optimized`
→ family `qwen3.8-flash-next` → `Qwen3.8-Flash-Next`.

## Applying

Append the trailer block as the last paragraph of the commit message, separated
by a blank line. Commit messages must be passed to `-m` as a single-quoted
literal, so the hook can read them; never pass a shell variable, a here-doc or
a file as the message — a message the hook cannot read is a message it cannot
verify, and it will block the commit.

Issue exactly one `git commit` per bash command. The hook reads a single commit
per shell command and injects into that one message; chaining several
`git commit`s in one command signs only the last message and leaves the others
unsigned.

## Hook behaviour

The global Pi extension `~/.pi/agent/extensions/commit-signature.ts` intercepts
every `bash` tool call containing `git commit`:

- Literal message (`-m '...'`, `--message=...`): the hook reads the message
  content; already signed (both trailers present) → untouched, no duplicate
  injection; unsigned → the trailer block is injected automatically.
- Messageless amend (`--amend --no-edit`, `-c`, `-C`): the message is HEAD's;
  the hook resolves it and passes the commit when HEAD is signed, and blocks
  otherwise.
- Anything it cannot read or sign: the commit is blocked (fail closed).

Because an amend message the hook cannot inject into is unverifiable, amend by
re-passing the full message literally with `-m`.
