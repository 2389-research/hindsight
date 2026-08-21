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

Read the archive's total session count first and set `<N>` to at least that
value. Two ways to get it — `ccvault orient --json` carries it at
`.database.sessions`, and `ccvault stats` prints it on the `Sessions:` line:

    ccvault orient --json 2>/dev/null    # read .database.sessions
    ccvault stats 2>/dev/null            # read the "Sessions:" line

The CLI does not paginate, so anything past `<N>` in the sorted list is
invisible. Pick `<N>` conservatively — session volume grows over time, and
the CLI returns quickly even at 100k rows.

Then filter client-side by **interval overlap with the window** (active-in-window
semantics matching agentsview's native `--date-from`/`--date-to`): keep rows
where `.started_at < <window_end>` AND (`.ended_at` is null OR `.ended_at >=
<window_start>`). A session that started before the window but was still
active during it counts as in-window; a session with a null `ended_at` is
treated as still open. Do NOT filter by `.started_at` alone — that misses
long-running sessions whose activity falls inside the window.

`<window_start>` and `<window_end>` are RFC3339 UTC instants, not the bare
`YYYY-MM-DD` dates Phase 0 resolves. Because hindsight's range is inclusive
of its end date, build them as:

- `<window_start>` = start date at `T00:00:00Z`
- `<window_end>` = the day **after** the end date at `T00:00:00Z` (exclusive)

So `2026-08-05` through `2026-08-11` becomes `2026-08-05T00:00:00Z` and
`2026-08-12T00:00:00Z`. Substituting a bare date for `<window_end>` breaks
the `.started_at < <window_end>` comparison and silently drops every
session that started on the end date.

Session rows include:

- `id` — session UUID (may be prefixed like `nanoclaw:<uuid>` for non-claude-code sources)
- `project_path`, `project_id`, `started_at`, `ended_at`
- `model`, `git_branch`, `turn_count`
- `input_tokens`, `output_tokens`, `cache_read_tokens`, `cache_write_tokens`
- `source_file`, `has_error`, `has_subagent`, `source`

The `source` field identifies which ccvault adapter produced the session
(`claude-code`, `nanoclaw`, `codex`, `hex`, `jeff`, …). Hindsight does not
filter by this — every session goes through the same extraction pipeline
and lens output naturally reflects what each session contains.

Note that `source` is the adapter name, not the tool hindsight read the row
from. Phase 1 tags rows with a separate `source_tool` field (`ccvault` or
`agentsview`) so the adapter value survives the merge.

**Session metadata (Phase 3 subagent):**

    ccvault show <session-id> --json

**Full transcript for extraction (Phase 3 subagent):**

    ccvault export <session-id> -o <output-file>

The exported markdown includes metadata, full conversation, tool usage,
tool results (default on), and thinking blocks (default on). Flags
`--no-thinking` and `--no-tool-results` can trim size for large sessions.

## agentsview

**Probe (Phase 0):** `command -v agentsview >/dev/null 2>&1 && agentsview session list --limit 1 --json 2>/dev/null | head -1`

**List sessions in date range (Phase 1):**

    agentsview session list --json --date-from <YYYY-MM-DD> --date-to <YYYY-MM-DD> --include-one-shot --include-automated

The CLI accepts native date-range flags (values are `YYYY-MM-DD`, not
RFC3339), so no client-side date filtering is needed here. `--include-one-shot`
and `--include-automated` opt in to rows agentsview excludes by default;
including them lets hindsight's own filters decide what to keep, and it
silences the "Excluded N sessions" stderr note that fires otherwise.

The response wraps rows in `{sessions: [...], next_cursor, total}`:
pagination is cursor-based (pass `--cursor <opaque>` to fetch the next
page), default `--limit` is 200, max is 500. `total` is the count of
matching rows across all pages, not the current page size.

Session rows carry 36 fields. Ones hindsight uses:

- `id` — session UUID (matches Claude Code's `sessionId` for Claude sessions, so ccvault and agentsview agree on IDs for the same session)
- `project`, `cwd` — short project name (inferred from cwd) and absolute cwd path
- `agent` — `"claude"`, `"codex"`, etc.; hindsight is source-agnostic and does not filter by this
- `started_at`, `ended_at` — RFC3339 with milliseconds and `Z` suffix
- `message_count`, `user_message_count` — size heuristics
- `first_message` — truncated preview of the initiating user turn
- `is_automated` — hindsight may want to skip these downstream
- `model`, `health_score` — surfaced for lens use

**Session metadata (Phase 3 subagent):**

    agentsview session get <id> --json

Returns a single JSON object (not wrapped). Superset of the list-row
shape with `health_score_basis` (array of contributing signals) and
`health_penalties` (object of applied penalties). Unknown IDs exit 1
with `fatal: session <id> not found` on stderr and no stdout — same
convention as ccvault.

**Full transcript for extraction (Phase 3 subagent):**

    agentsview session messages <id> --json --limit <N> --from <ordinal> --role user,assistant

Chose `session messages --json` over `session export` because it returns
a uniform normalized shape across agent types, matching hindsight's
source-agnostic design — the extraction subagent doesn't need per-agent
parsing knowledge. (`session export` streams raw agent-native JSONL,
which for Claude sessions is Claude Code's on-disk format and for other
agents is their native format.)

Response shape:

    {messages: [{id, session_id, ordinal, role, content, thinking_text, timestamp, has_tool_use, model, ...}, ...], count, first_ordinal, last_ordinal}

`--from <ordinal>` and `--limit <N>` paginate through the `messages`
array; `--role user,assistant` filters turn types.

**Daemon and auth notes.** Daemon lifecycle is auto-managed by
`agentsview sync`; there is no manual `daemon start` step. The localhost
API is un-authenticated by default (`require_auth: false`); the
`auth_token` in `~/.agentsview/config.toml` applies only to remote or
`--server` requests, so the CLI path needs no auth handling.
