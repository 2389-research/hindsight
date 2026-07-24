<!-- ABOUTME: Canonical per-source CLI contracts for hindsight session-log sources. -->
<!-- ABOUTME: One section per source. Referenced by SKILL.md Phase 0/1 and by extraction-prompt.md subagent template. -->

# Session Log Sources

Hindsight reads session data through one of two interchangeable local-first
tools. This file is the single source of truth for how each is invoked.
Both are multi-agent at the ingestion layer and normalize their data into
a common session/turn/tool-call shape before hindsight sees it.

Adding a future third source is a new `## <source-name>` section here plus
one probe in SKILL.md Phase 0.

## ccvault

**Probe (Phase 0):** `command -v ccvault >/dev/null 2>&1 && ccvault orient --json 2>/dev/null | head -1`

**List sessions in date range (Phase 1):**

    ccvault list-sessions --json --limit <N> 2>&1

Then filter client-side by `started_at` (JSON field, ISO-8601 string) since
the CLI does not accept `--after`/`--before` flags. Session rows include:

- `id` — session UUID (may be prefixed like `nanoclaw:<uuid>` for non-claude-code sources)
- `project_path`, `project_id`, `started_at`, `ended_at`
- `model`, `git_branch`, `turn_count`
- `input_tokens`, `output_tokens`, `cache_read_tokens`, `cache_write_tokens`
- `source_file`, `has_error`, `has_subagent`, `source`

The `source` field identifies which ccvault adapter produced the session
(`claude-code`, `nanoclaw`, `codex`, `hex`, `jeff`, …). Hindsight does not
filter by this — every session goes through the same extraction pipeline
and lens output naturally reflects what each session contains.

**Session metadata (Phase 3 subagent):**

    ccvault show <session-id> --json

**Full transcript for extraction (Phase 3 subagent):**

    ccvault export <session-id> -o <output-file>

The exported markdown includes metadata, full conversation, tool usage,
tool results (default on), and thinking blocks (default on). Flags
`--no-thinking` and `--no-tool-results` can trim size for large sessions.

## agentsview

(Placeholder — filled in by Task 2.)
