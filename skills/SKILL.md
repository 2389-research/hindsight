<!-- ABOUTME: Main orchestrator skill for the cc-review plugin. -->
<!-- ABOUTME: Dispatches subagents to summarize sessions, then applies a lens for cross-cutting analysis. -->

---
name: cc-review
description: Analyze Claude Code session logs through configurable lenses. Use when asked to review, summarize, or analyze session history.
args: date-range [lens-name]
---

# CC Review — Session Log Analyzer

## Arguments

This skill accepts arguments in the format: `<date-range> [lens-name]`

**Date range formats:**
- `today`, `yesterday`
- `last-week` (7 days), `last-month` (30 days)
- `last-N-days` (e.g., `last-3-days`)
- `YYYY-MM-DD` (single day)
- `YYYY-MM-DD:YYYY-MM-DD` (explicit range)

**Lens name:** Name of a lens file (without `.md`). Default: `standup`.

**Examples:**
- `/cc-review today standup`
- `/cc-review last-week knowledge-extraction`
- `/cc-review 2026-03-01:2026-03-05 workflow-optimization`
- `/cc-review yesterday` (uses default lens)

## Prerequisites

User directories must exist at `~/.claude/cc-review/`. If they don't, run the install
script first:

```bash
bash <plugin-base-dir>/scripts/install.sh
```

Where `<plugin-base-dir>` is the base directory shown in the skill loading message above.

## Pipeline

Follow these phases in order. Do not skip phases.

### Phase 0: Parse Arguments and Validate

1. Parse the arguments string to extract date-range and lens-name
2. Resolve the date range to start and end dates (YYYY-MM-DD format). Use the Bash tool with `date` command for date math:
   - `today` → today's date for both start and end
   - `yesterday` → yesterday's date for both
   - `last-week` → 7 days ago through today
   - `last-month` → 30 days ago through today
   - `last-N-days` → N days ago through today
   - `YYYY-MM-DD` → that date for both start and end
   - `YYYY-MM-DD:YYYY-MM-DD` → start and end as given
3. If no lens specified, use `standup` as default
4. Verify `~/.claude/cc-review/lenses/` exists
   - If not found, tell the user to run the install script and stop
5. Verify the lens file exists at `~/.claude/cc-review/lenses/<lens-name>.md`
   - If not found, list available lenses and stop

### Phase 1: Collect Sessions

Run the collect-sessions script to get the manifest:

```bash
bash <plugin-base-dir>/scripts/collect-sessions.sh <start-date> <end-date>
```

Parse the JSON output. If the manifest is empty (`[]`), report "No sessions found
for the specified date range" and stop.

Report to the user: "Found N sessions across M projects for <date-range>."

### Phase 2: Load Lens

1. Read the lens file from `~/.claude/cc-review/lenses/<lens-name>.md`
2. Check if it has an `## Extraction Hints` section
3. If it does, extract the text of that section — it will be appended to the extraction prompt

### Phase 3: Extract Session Summaries (Parallel Subagents)

For each session in the manifest, dispatch a subagent using the Agent tool to produce a session summary.

**Constructing the subagent prompt:**

For each session, construct the subagent prompt by combining:
1. The extraction prompt from `<plugin-base-dir>/skills/shared/extraction-prompt.md` (read it once and reuse)
2. The session summary schema from `<plugin-base-dir>/skills/shared/session-summary-schema.md` (read it once and reuse)
3. If the lens has extraction hints, replace `{LENS_EXTRACTION_HINTS}` in the extraction prompt with those hints. If no hints, replace with empty string.
4. The specific session metadata from the manifest entry (path, project, sessionId, etc.)

The subagent prompt should be structured as:

```
You are a session extraction agent. Your job is to read a Claude Code session log
and produce a standardized summary.

## Your Task

Read the session log at: {session_path}
This session is from project: {project} ({projectPath})
Session ID: {sessionId}

## Instructions

{contents of extraction-prompt.md, with {LENS_EXTRACTION_HINTS} replaced}

## Output Schema

{contents of session-summary-schema.md}

## Output

Produce ONLY the session summary markdown. No preamble, no commentary.
```

**Batching:**
- Dispatch subagents in parallel batches of up to 5
- Wait for each batch to complete before starting the next
- Report progress: "Summarized N/M sessions..."

**Error handling:**
- If a subagent fails, log the error and continue with remaining sessions
- Include a note in the final report about any failed extractions

### Phase 4: Cross-Cutting Analysis

Once all session summaries are collected:

1. Read the full lens file from `~/.claude/cc-review/lenses/<lens-name>.md`
2. Extract the `# Analysis Instructions` section (everything between `# Analysis Instructions` and `## Extraction Hints`, or end of file if no extraction hints)
3. Combine ALL session summaries into your context
4. Apply the lens analysis instructions to produce the final report
5. The report should follow the format specified in the lens

### Phase 5: Write Report

1. Determine the output path:
   - For single dates or named ranges resolving to a single day: `~/.claude/cc-review/reports/YYYY-MM-DD/<lens-name>.md`
   - For multi-day ranges: `~/.claude/cc-review/reports/YYYY-MM-DD_to_YYYY-MM-DD/<lens-name>.md`
2. Create the directory if needed using `mkdir -p`
3. Write the report file using the Write tool
4. Report to the user: "Report written to <path>"
5. Display the full report to the user
