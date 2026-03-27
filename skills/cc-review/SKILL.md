<!-- ABOUTME: Main orchestrator skill for the cc-review plugin. -->
<!-- ABOUTME: Dispatches subagents to summarize sessions, then applies a lens for cross-cutting analysis. -->

---
name: cc-review
description: Analyze Claude Code session logs through configurable lenses. Use when asked to review, summarize, or analyze session history.
args: freeform natural language (or structured date + lens)
---

# CC Review — Session Log Analyzer

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

1. **ccvault** must be installed and synced. Verify by running:
   ```bash
   ccvault orient --json 2>/dev/null | head -1
   ```
   If this fails, tell the user to install ccvault (`brew install 2389-research/tap/ccvault`)
   and run `ccvault sync` first.

2. **ccvault MCP server** must be available. The skill uses ccvault's MCP tools
   (`search_conversations`, `get_session_summary`, `get_turns`, `list_sessions`)
   to read session data. If MCP tools are not available, fall back to the ccvault CLI.

3. **User directories** must exist at `~/.claude/cc-review/`. If they don't, run:
   ```bash
   bash <plugin-root>/scripts/install.sh
   ```
   Where `<plugin-root>` is determined by taking the skill base directory shown in the
   loading message above and going up two levels.

## Pipeline

Follow these phases in order. Do not skip phases.

### Phase 0: Interpret Input and Validate

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
- `~/.claude/cc-review/lenses/` (user/built-in lenses)
- `<project-root>/.claude/cc-review/lenses/` (project-scoped lenses)

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

Use ccvault to find sessions in the date range. Try the MCP tool first, fall back to CLI:

**Via MCP (preferred):**
Call `list_sessions` and filter results by date range. If a project filter is relevant
(from the user's input), include it.

**Via CLI (fallback):**
```bash
ccvault list-sessions --after <start-date> --before <end-date> --json
```

If no sessions are found, report "No sessions found for the specified date range" and stop.

Report to the user: "Found N sessions across M projects for <date-range>."

### Phase 2: Load Lens

1. Read the lens file from its resolved location (check project lenses first,
   then user lenses: `<project-root>/.claude/cc-review/lenses/<lens-name>.md`,
   falling back to `~/.claude/cc-review/lenses/<lens-name>.md`)
2. Check if it has an `## Extraction Hints` section
3. If it does, extract the text of that section — it will be appended to the extraction prompt
4. Extract the `version` field from the lens frontmatter. If not present, default to `1`

### Phase 3: Extract Session Summaries (Parallel Subagents)

For each session, dispatch a subagent to produce a summary using ccvault's MCP tools.
This keeps subagent context out of the main conversation.

**Cache check:**

Before extracting, check if summaries already exist at
`~/.claude/cc-review/reports/<date-range>/summaries/`. For each session in the list,
check if `<sessionId>.md` exists in that directory. If ALL sessions have existing
summaries, skip extraction entirely and report:
"Found cached summaries for N sessions. Skipping extraction."

If SOME sessions have summaries but others don't, extract only the missing ones and report:
"Found cached summaries for X/N sessions. Extracting Y remaining..."

**Setup:**

Before dispatching subagents, create the summaries staging directory:

```bash
mkdir -p ~/.claude/cc-review/reports/<date-range>/summaries
```

Where `<date-range>` follows the same format as the report output path (e.g., `2026-03-23`
for a single day, `2026-03-20_to_2026-03-23` for a range).

**Constructing the subagent prompt:**

For each session, construct the subagent prompt by combining:
1. The extraction prompt from `<plugin-root>/skills/shared/extraction-prompt.md` (read it once and reuse)
2. The session summary schema from `<plugin-root>/skills/shared/session-summary-schema.md` (read it once and reuse)
3. If the lens has extraction hints, replace `{LENS_EXTRACTION_HINTS}` in the extraction prompt with those hints. If no hints, replace with empty string.
4. The session ID, project name, and project path from the session list
5. The output file path where the subagent should write its summary

The subagent prompt should be structured as:

```
You are a session extraction agent. Your job is to read a Claude Code session
via ccvault's MCP tools and produce a standardized summary.

## Your Task

Analyze session: {sessionId}
Project: {project} ({projectPath})

## How to Read the Session

Use ccvault's MCP tools to access session data. Follow this sequence:

1. Call `get_session_summary` with session_id to get metadata, turn counts,
   token usage, tools used, and first/last messages.
2. Call `get_turns` with session_id, paginating through all turns (limit=50,
   increment offset). Use type="user" first to understand what the human asked,
   then type="assistant" to see responses and tool usage.
3. For long sessions (100+ turns), focus on user turns to understand the arc,
   then sample assistant turns at key decision points rather than reading every turn.

## Instructions

{contents of extraction-prompt.md, with {LENS_EXTRACTION_HINTS} replaced}

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
3. Read ALL session summary files from `~/.claude/cc-review/reports/<date-range>/summaries/`
4. Apply the lens analysis instructions to produce the final report
5. The report should follow the format specified in the lens

**Aggregation compliance rules:**

These rules apply when producing the final report. They override any conflicting
instinct to be helpful or thorough:

- **Only include work from the requested date range.** Do not attribute work from
  other dates. If a summary's date falls outside the range, exclude it entirely.
- **Follow the lens heading hierarchy exactly.** Use the heading levels specified
  in the lens format section. Do not promote or demote headings.
- **Follow lens content principles literally.** If the lens says "prefer outcomes
  over implementation detail," do not include implementation detail. If it says
  "no ideation," exclude brainstorming. Re-read the principles before writing
  each section.
- **Do not fabricate.** Every claim in the report must trace to a specific session
  summary. If no summary mentions a blocker, do not invent one. If no summary
  mentions a PR, do not reference one.
- **Use project descriptions from summaries.** When a session summary includes a
  Project Description, use it to give readers context on first mention of that
  project in the report.

### Phase 5: Write Report

1. Determine the output path:
   - For single dates or named ranges resolving to a single day: `~/.claude/cc-review/reports/YYYY-MM-DD/<lens-name>.md`
   - For multi-day ranges: `~/.claude/cc-review/reports/YYYY-MM-DD_to_YYYY-MM-DD/<lens-name>.md`
2. Create the directory if needed using `mkdir -p`
3. Write the report file using the Write tool. Include a version line after the report title:
   `*Generated with <lens-name> lens v<version>*`
4. Report to the user: "Report written to <path>"
5. Display the full report to the user
