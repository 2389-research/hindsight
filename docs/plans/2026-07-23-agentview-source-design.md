# Design — agentsview as an alternative session source

Date: 2026-07-23
Branch: `feature/agentview-source`

## Problem

Hindsight currently reads Claude Code session data exclusively through
[ccvault](https://github.com/2389-research/ccvault). The `README.md`
Limitations section calls this out: "ccvault is a hard dependency. If
ccvault isn't installed and synced, nothing works."

[AgentsView](https://agentsview.io) (kenn-io/agentsview) is a local-first
session indexer with the same shape — SQLite backed, CLI + web UI, one
binary, brew-installable — but with two capabilities ccvault doesn't have:
support for 20+ coding agents (Claude Code, Codex, Devin, Forge, OpenCode,
…) and a broader deployment story (Docker, Postgres, DuckDB, S3-backed
roots).

Some users use ccvault, some will move to agentsview, some may have both
installed side-by-side. Hindsight should support all three, without
forcing a config file or breaking existing installs.

## Non-goals

- Multi-agent extraction (Codex/Devin sessions). The extraction prompt is
  Claude-shaped. Adding non-Claude support is a separate future design.
- A first-party MCP server for agentsview.
- Deprecating ccvault. Existing installs must produce byte-identical
  reports after this change.
- Any change to lens files, session-summary schema, or report format.

## Approach

### Layering

New file `skills/shared/sources.md` becomes the canonical "how to talk to a
session-log tool" doc. One `## ccvault` section, one `## agentsview`
section, each self-contained with the probe command, list-sessions call,
show/export calls, and data-shape notes. Adding a future third source is
one new section here + one probe in Phase 0.

- **`skills/shared/sources.md`** (NEW) — per-source CLI contract.
- **`skills/hindsight/SKILL.md`** — Phase 0 gets a detect-sources step;
  Phase 1 queries each available source and dedupes; Prerequisites updates
  from "ccvault required" to "at least one of ccvault or agentsview".
- **`skills/shared/extraction-prompt.md`** — parameterized on `{source}`
  so each subagent's prompt embeds only its assigned source's toolset.
  No "try X then Y" branching inside subagents.
- **`README.md`** — Prerequisites + Limitations updated.
- **`AGENTS.md`** — dependency description updated.

Everything above the source layer (lens files, `session-summary-schema.md`,
analysis instructions, cache format) is untouched.

### Detection and selection

- **Auto-detect at Phase 0.** Probe `command -v ccvault` and
  `command -v agentsview`; for each present binary, run one cheap health
  check to confirm it's actually usable. Both, one, or neither can be
  available.
- **No config file.** Runtime detection is enough; a config file would be
  another install step for zero benefit given the two-tool ceiling.
- **Both installed → parallel merge, naive dedup.** Query both in Phase
  1, tag each session row with `source: "ccvault" | "agentsview"`, dedupe
  by session ID, prefer ccvault when the same ID surfaces in both (older
  tool, extraction assumptions already match its field names).
- **Rare-both is not a hot path.** Users with both installed are
  expected to be uncommon; the dedup rule stays simple.

### Interface

CLI only. Not MCP.

- Even for ccvault, our subagents overwhelmingly use the CLI in practice
  (the MCP tools aren't always available; falling back to CLI is the
  actual behavior).
- AgentsView's MCP is community-maintained (`rgr4y/agentsview-mcp`,
  `mjacobs/agentsview-mcp`) and requires a separate `npm install`. Not
  first-party.
- CLI-only is one dependency per source, no auth-token handling for
  localhost daemons, and the interface is stable across `agentsview`
  binary versions.

## Data flow

**Phase 0 — Detect available sources.** New step. Probe both binaries;
build `available = [<source>, ...]`. If empty: hard fail with an install
pointer to each tool. If exactly one: use it exclusively (identical to
today's ccvault-only path with agentsview substituted when appropriate).

**Phase 1 — Collect sessions.** For each source in `available`, call
its list-sessions endpoint over the date range. Concatenate results,
tagging each row with `source`. Dedupe by session ID (prefer ccvault on
tie). Filter automated/synthetic sessions as today.

**Phase 2 — Load lens.** Unchanged.

**Phase 3 — Extract summaries.** Subagent prompt template takes a
`{source}` parameter. Look up the relevant `## <source>` section from
`sources.md` and inline its "How to read" instructions into the subagent
prompt. Each subagent sees exactly one toolset. Cache path
(`~/.claude/hindsight/reports/<date-range>/summaries/<sessionId>.md`) is
source-agnostic; cache hits work across sources.

**Phase 4/5 — Analysis + Write.** Unchanged.

Two properties worth naming:

1. **Source tag lives only until subagent dispatch.** The summary schema
   stays source-agnostic; lenses don't need to know which tool produced a
   summary. Adding a source-metadata field to the schema is a future
   design decision, not required here.
2. **Cache is source-agnostic.** A session summarized via ccvault today
   and re-listed via agentsview tomorrow re-uses the ccvault-produced
   cache entry. Fine — the schema is intentionally about the *session*,
   not the *reader*.

## Error handling

**Phase 0**

- Zero sources installed → halt with:
  `"No session log source found. Install one of: ccvault
  (brew install 2389-research/tap/ccvault) or agentsview
  (brew install --cask agentsview)."`
- Source installed but health check fails (daemon not running, DB
  locked, etc.) → treat as "not available for this run"; if the other
  source is available, proceed with that; if not, halt with the specific
  health-check error.
- Source installed but not yet synced → same as "not available for this
  run" plus a hint that the user should sync explicitly. Hindsight does
  not auto-sync.

**Phase 1**

- One source errors, other returns rows → log error to stderr, proceed
  with working source's rows. Better than dropping the whole run.
- Both return zero rows for the range → existing "No sessions found"
  halt.
- Same ID with divergent metadata across sources → dedup preferring
  ccvault; log a one-line notice.

**Phase 3**

- Subagent extraction failure: existing per-session error handling,
  extended to include the source tag in the error line
  (`"failed to extract <session-id> via <source>: <error>"`) so triage
  isn't guessing.
- Wrong toolset for a source-tagged session (bug in the source-lookup
  path) → CLI call fails at the first command. Loud failure, not silent.

## Testing

- **Regression: single-source ccvault** — Run `standup` against a known
  ccvault-covered day before and after. Diff should be empty modulo the
  new "sources detected" preamble line.
- **Smoke: single-source agentsview** — Install agentsview, sync, run
  `standup` against a covered range. Verify Phase 0 detection, Phase 1
  session listing, Phase 3 extraction, final report render.
- **Smoke: both-installed dedup path** — Verify session count matches
  the ccvault-only run; verify each subagent's transcript reflects the
  tool tagged on its session row.
- **Missing/corrupted scenarios** — Stop agentsview daemon → graceful
  degrade to ccvault. Rename ccvault binary → graceful degrade to
  agentsview. Remove both → halt message.
- **Lens compatibility sweep** — Run all 7 built-in lenses once
  ccvault-only against a small range. No lens changes should be needed.
  If any lens references a source-specific field, that's a design leak.
- **Not tested** — Non-Claude agents in agentsview. Out of scope; the
  extraction prompt is Claude-shaped.

## Open questions (deferred, not blocking)

- **AgentsView's session-level CLI shape.** README documents
  `agentsview session list` and `agentsview sync` explicitly. The
  equivalents of `ccvault show <id> --json` and
  `ccvault export <id> -o <file>` need verification against a real
  install. If not present, fall back to the HTTP API for those two
  operations, invoked via `curl` against `127.0.0.1:8080/api/v1/...`
  (still no MCP dependency; auth-token lookup from
  `~/.agentsview/config.toml` if the daemon requires it).
- **Preserve source tag in summary metadata?** Design keeps summaries
  source-agnostic. If a future lens wants to filter by source (e.g.,
  "Codex-only usage patterns"), we'd add a `Source:` row to the metadata
  table. Not part of this design.

## What we're explicitly not deciding here

- Multi-agent extraction. Codex/Devin/Forge sessions are structurally
  different from Claude sessions. Supporting them will require a new
  extraction prompt (or per-agent extraction prompts). Not here.
- First-party agentsview MCP. Even if one lands, our subagents use CLI
  in practice; adopting MCP later would be a swap-in at the sources.md
  section level, not a re-architecture.
- Deprecating ccvault. It works; users use it; nothing to gain by
  removing it.
