---
name: hindsight
description: Analyze Claude Code session logs through configurable lenses. Use when asked to review, summarize, or analyze session history.
args: freeform natural language (or structured date + lens)
---

<!-- ABOUTME: Main orchestrator skill for the hindsight plugin. -->
<!-- ABOUTME: Dispatches subagents to summarize sessions, then applies a lens for cross-cutting analysis. -->

# Hindsight — Session Log Analyzer

## Input

This skill accepts freeform natural language describing what the user wants to analyze.
The LLM interprets the input to determine two things:

1. **Date range** — when to look
2. **Lens** — what kind of analysis to produce

**Examples of valid input:**

- `yesterday standup`
- `what knowledge can we extract from last week's sessions?`
- `summarize what happened today`
- `review the last 3 days for workflow optimization opportunities`
- `2026-03-01:2026-03-05 knowledge-extraction`
- `what did I work on this past week?`

Structured formats like `yesterday standup` still work — the skill handles both.

## Prerequisites

1. **A session log source** must be installed and synced. Currently supported:
   - **ccvault** (`brew install 2389-research/tap/ccvault && ccvault sync`)

   See `skills/shared/sources.md` for probe commands and CLI contracts.

2. **User directories** must exist at `~/.claude/hindsight/`. If they don't, run:

   ```bash
   bash <plugin-root>/scripts/install.sh
   ```

   Where `<plugin-root>` is determined by taking the skill base directory shown in the
   loading message above and going up two levels.

## Pipeline

Follow these phases in order. Do not skip phases.

### Phase 0: Interpret Input and Validate

**Step 0: Detect available sources**

Before doing anything else, probe which session-log sources are installed and healthy. Read `skills/shared/sources.md` and for each `## <source>` section, run its **Probe** command. Build an `AVAILABLE_SOURCES` list containing every source whose probe succeeds.

    AVAILABLE_SOURCES=""

    # ccvault
    if command -v ccvault >/dev/null 2>&1 && ccvault orient --json >/dev/null 2>&1; then
      AVAILABLE_SOURCES="$AVAILABLE_SOURCES ccvault"
    fi

    # agentsview
    if command -v agentsview >/dev/null 2>&1 && agentsview session list --limit 1 --json >/dev/null 2>&1; then
      AVAILABLE_SOURCES="$AVAILABLE_SOURCES agentsview"
    fi

If `AVAILABLE_SOURCES` is empty, halt and tell the user:

> No session log source found. Install one of:
>
> - ccvault: `brew install 2389-research/tap/ccvault && ccvault sync`
> - agentsview: `brew install --cask agentsview && agentsview sync`

If exactly one source is available, use it exclusively (single-source path — identical to today's ccvault-only behavior with agentsview substituted when appropriate).

If both are available, proceed with dual-source Phase 1 (see next task — for now, treat this as a soft flag to plumb through, since dual-source merge is wired in Task 4).

**Step 1: Determine date range**

Interpret the user's input to extract a date range. Resolve to start and end dates
(YYYY-MM-DD format). Use the Bash tool with `date` command for date math.

Common patterns:

- "today" / "yesterday" / "last week" / "last month" / "last N days"
- "this past week" / "since Monday" / "March 1st through 5th"
- Explicit formats like `2026-03-23` or `2026-03-01:2026-03-05`

If the date range is ambiguous, ask the user to clarify.

**Step 2: Determine lens**

Read the available lenses from both locations (list both directories):

- `~/.claude/hindsight/lenses/` (user/built-in lenses)
- `<project-root>/.claude/hindsight/lenses/` (project-scoped lenses)

Project lenses take precedence if a name collision occurs.

Match the user's intent to the best available lens:

- Explicit lens name (exact or partial match): `knowledge` → `knowledge-extraction`
- Intent-based matching: "what did I learn" → `knowledge-extraction`, "standup summary" → `standup`, "improve my workflow" → `workflow-optimization`
- If no lens intent is expressed, default to `standup`
- If the intent doesn't clearly match any available lens, list the options and ask

**Step 3: Confirm interpretation**

Before proceeding, briefly state what you understood:
"Analyzing <date-range> with the <lens-name> lens."

If neither lenses directory exists, tell the user to run the install script and stop.

### Phase 1: Collect Sessions

For each source in `AVAILABLE_SOURCES` (from Phase 0):

1. Look up its `## <source>` section in `skills/shared/sources.md`
2. Run its list-sessions command over the date range from Phase 0
3. Parse the JSON output
4. Tag each session row with `source: "<source-name>"`
5. Filter client-side by the source's timestamp field where the source's CLI doesn't natively support date-range flags (ccvault requires this; agentsview does not since its `--date-from`/`--date-to` handle it natively)

Concatenate all tagged rows. Dedupe by session `id`: if the same ID appears from two sources, keep the ccvault-sourced row and drop the agentsview one. This is a naive tie-break — ccvault is preferred because its extraction assumptions match its field names, and the "both installed with overlapping coverage" case is uncommon.

If the final merged list is empty: halt with "No sessions found for the specified date range."

Report to the user: "Found N sessions across M projects for <date-range> (sources: <comma-separated-list>)."

The tagged `source` field on each session row propagates into Phase 3 for source-aware subagent dispatch (see Task 5).

### Phase 2: Load Lens

1. Read the lens file from its resolved location (check project lenses first,
   then user lenses: `<project-root>/.claude/hindsight/lenses/<lens-name>.md`,
   falling back to `~/.claude/hindsight/lenses/<lens-name>.md`)
2. Check if it has an `## Extraction Hints` section
3. If it does, extract the text of that section — it will be appended to the extraction prompt
4. Extract the `version` field from the lens frontmatter. If not present, default to `1`

### Phase 3: Extract Session Summaries (Parallel Subagents)

For each session, dispatch a subagent to produce a summary using the session's
source CLI (see `skills/shared/sources.md`). This keeps subagent context out of
the main conversation.

**Cache check:**

Before extracting, check if summaries already exist at
`~/.claude/hindsight/reports/<date-range>/summaries/`. For each session in the list,
check if `<sessionId>.md` exists in that directory. If ALL sessions have existing
summaries, skip extraction entirely and report:
"Found cached summaries for N sessions. Skipping extraction."

If SOME sessions have summaries but others don't, extract only the missing ones and report:
"Found cached summaries for X/N sessions. Extracting Y remaining..."

**Setup:**

Before dispatching subagents, create the summaries staging directory:

```bash
mkdir -p ~/.claude/hindsight/reports/<date-range>/summaries
```

Where `<date-range>` follows the same format as the report output path (e.g., `2026-03-23`
for a single day, `2026-03-20_to_2026-03-23` for a range).

**Constructing the subagent prompt:**

For each session, construct the subagent prompt by combining:

1. The extraction prompt from `<plugin-root>/skills/shared/extraction-prompt.md` (read it once and reuse)
2. The session summary schema from `<plugin-root>/skills/shared/session-summary-schema.md` (read it once and reuse)
3. If the lens has extraction hints, replace `{LENS_EXTRACTION_HINTS}` in the extraction prompt with those hints. If no hints, replace with empty string.
4. **Source-specific instructions** — for each session, use the `source` field tagged in Phase 1 to look up the matching `## <source>` section of `skills/shared/sources.md`. Inline that section's CLI-contract content in place of `{SOURCE_CLI_CONTRACT}`, and inline the source name (e.g., `ccvault` or `agentsview`) in place of `{source}`. Different sessions in the same run may resolve to different sources.
5. The session ID, project name, and project path from the session list
6. The date range being analyzed
7. The output file path where the subagent should write its summary

The subagent prompt should be structured as:

```text
You are a session extraction agent. Your job is to read a session
and produce a standardized summary.

## Your Task

Analyze session: {sessionId}
Project: {project} ({projectPath})
Date range: {startDate} to {endDate}

**IMPORTANT: Only summarize activity that occurred within the date range above.**
This session may span a longer period, but your summary must only cover what
happened between {startDate} and {endDate}. Use turn timestamps to determine
which activity falls within the window. If no activity occurred in this window,
write a summary with just the Metadata section and note "No activity in date range"
in the What Happened section.

**Filter by date range.** Each turn has a timestamp. Skip turns outside the
requested date range. Only include activities, decisions, and outcomes from
turns within the window.

## Instructions

{contents of extraction-prompt.md, with {source}, {SOURCE_CLI_CONTRACT}, and {LENS_EXTRACTION_HINTS} replaced}

## Output Schema

{contents of session-summary-schema.md}

## Output

Write your session summary markdown to this file using the Write tool:
{summaries_dir}/{sessionId}.md

Write ONLY the session summary markdown to the file. No preamble, no commentary.
After writing, respond with just the file path to confirm completion.
```

**Batching:**

- Dispatch subagents in parallel batches of up to 5
- Wait for each batch to complete before starting the next
- Report progress: "Summarized N/M sessions..."

**Error handling:**

- If a subagent fails, log the error and continue with remaining sessions
- Include a note in the final report about any failed extractions

### Phase 4: Cross-Cutting Analysis

Once all session summaries have been written to disk:

1. Read the full lens file from its resolved location (same precedence as Phase 2)
2. Extract the `# Analysis Instructions` section (everything between `# Analysis Instructions` and `## Extraction Hints`, or end of file if no extraction hints)
3. Read ALL session summary files from `~/.claude/hindsight/reports/<date-range>/summaries/`
4. Apply the lens analysis instructions to produce the final report
5. The report should follow the format specified in the lens

**Aggregation compliance rules:**

- **Date range is a hard filter.** Do not attribute work from other dates. If
  a summary covers a wider range than requested, only include activity that
  can be specifically tied to the requested dates.
- **Do not fabricate.** Every claim must trace to a session summary. Do not
  invent next steps, blockers, or context that does not appear in any summary.
- **Omit rather than pad.** If a project has no specific activity for the date
  range, leave it out entirely — do not write "continued development" filler.

### Phase 5: Write Report

1. Determine the output path:
   - For single dates or named ranges resolving to a single day: `~/.claude/hindsight/reports/YYYY-MM-DD/<lens-name>.md`
   - For multi-day ranges: `~/.claude/hindsight/reports/YYYY-MM-DD_to_YYYY-MM-DD/<lens-name>.md`
2. Create the directory if needed using `mkdir -p`
3. Write the report file using the Write tool. Include a version line after the report title:
   `*Generated with <lens-name> lens v<version>*`
4. Report to the user: "Report written to <path>"
5. Display the full report to the user
