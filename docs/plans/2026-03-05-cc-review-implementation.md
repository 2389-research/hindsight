# CC Review Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Claude Code plugin that analyzes session logs through configurable lenses, producing markdown reports.

**Architecture:** Two-phase pipeline — a bash script filters JSONL session files by date range, then the skill orchestrates parallel subagents to summarize each session, and a final fan-in phase applies a lens prompt for cross-cutting analysis. Output is markdown reports written to `~/.claude/cc-review/reports/`.

**Tech Stack:** Bash (collect-sessions.sh), Claude Code skill (SKILL.md), markdown lens files.

---

### Task 1: Plugin Scaffold

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `CLAUDE.md`

**Step 1: Create plugin.json**

```json
{
  "name": "cc-review",
  "description": "Analyze Claude Code session logs through configurable lenses to produce summary reports",
  "version": "1.0.0"
}
```

**Step 2: Create CLAUDE.md**

```markdown
# CC Review Plugin

This plugin provides the `cc-review` skill for analyzing Claude Code session logs.

## Usage

Interactive: `/cc-review <date-range> <lens-name>`
Headless: `claude -p "use the cc-review skill for <date-range> with the <lens-name> lens"`
```

**Step 3: Commit**

```bash
git add .claude-plugin/plugin.json CLAUDE.md
git commit -m "feat: scaffold cc-review plugin"
```

---

### Task 2: collect-sessions.sh

This is the data layer — filters JSONL files by date range and outputs a JSON manifest.

**Files:**
- Create: `scripts/collect-sessions.sh`

**Step 1: Write collect-sessions.sh**

The script needs to:
1. Accept date range arguments (start date, end date as YYYY-MM-DD)
2. Walk `~/.claude/projects/*/` for `*.jsonl` files
3. Extract timestamps from first and last lines of each file
4. Filter files whose session overlaps the requested date range
5. Output JSON manifest to stdout

**Important JSONL timestamp details:**
- Timestamps are ISO 8601: `YYYY-MM-DDTHH:MM:SS.fffZ`
- Top-level `timestamp` field exists on most entry types
- `file-history-snapshot` entries may only have `snapshot.timestamp`
- First line may lack a top-level timestamp — fall back to checking a few lines
- Use `jq` for reliable JSON parsing: `.timestamp // .snapshot.timestamp // empty`

```bash
#!/usr/bin/env bash
# ABOUTME: Collects Claude Code session JSONL files matching a date range.
# ABOUTME: Outputs a JSON manifest with session metadata for downstream analysis.

set -euo pipefail

usage() {
  echo "Usage: $0 <start-date> <end-date>"
  echo "  Dates in YYYY-MM-DD format"
  echo "  Outputs JSON manifest of matching session files to stdout"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

START_DATE="$1"
END_DATE="$2"

# Validate date format
if ! [[ "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! [[ "$END_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: Dates must be in YYYY-MM-DD format" >&2
  exit 1
fi

# Convert to comparable timestamps (start of start day, end of end day)
START_TS="${START_DATE}T00:00:00.000Z"
END_TS="${END_DATE}T23:59:59.999Z"

PROJECTS_DIR="${HOME}/.claude/projects"

if [[ ! -d "$PROJECTS_DIR" ]]; then
  echo "Error: Projects directory not found at $PROJECTS_DIR" >&2
  exit 1
fi

# Extract timestamp from a JSONL line, handling both top-level and nested timestamps
extract_timestamp() {
  echo "$1" | jq -r '.timestamp // .snapshot.timestamp // empty' 2>/dev/null
}

# Extract the first valid timestamp from first N lines of a file
get_first_timestamp() {
  local file="$1"
  local ts=""
  while IFS= read -r line; do
    ts=$(extract_timestamp "$line")
    if [[ -n "$ts" ]]; then
      echo "$ts"
      return
    fi
  done < <(head -n 5 "$file")
  echo ""
}

# Extract the last valid timestamp from last N lines of a file
get_last_timestamp() {
  local file="$1"
  local ts=""
  local last_ts=""
  while IFS= read -r line; do
    ts=$(extract_timestamp "$line")
    if [[ -n "$ts" ]]; then
      last_ts="$ts"
    fi
  done < <(tail -n 5 "$file")
  echo "$last_ts"
}

# Decode project path from directory name
# e.g., "-Users-dylanr-work-2389-boba" -> "/Users/dylanr/work/2389/boba"
decode_project_path() {
  local dirname="$1"
  echo "$dirname" | sed 's/^-/\//' | sed 's/-/\//g'
}

# Extract project name (last path component) from decoded path
get_project_name() {
  local decoded="$1"
  basename "$decoded"
}

# Try to extract session slug from the file (from system entries)
get_session_slug() {
  local file="$1"
  # Look in last 20 lines for system entries with slug
  tail -n 20 "$file" | jq -r 'select(.type == "system") | .slug // empty' 2>/dev/null | head -n 1
}

# Build manifest
echo "["
first_entry=true

for project_dir in "$PROJECTS_DIR"/*/; do
  [[ -d "$project_dir" ]] || continue

  project_dirname=$(basename "$project_dir")
  project_path=$(decode_project_path "$project_dirname")
  project_name=$(get_project_name "$project_path")

  for jsonl_file in "$project_dir"*.jsonl; do
    [[ -f "$jsonl_file" ]] || continue

    # Skip empty files
    [[ -s "$jsonl_file" ]] || continue

    first_ts=$(get_first_timestamp "$jsonl_file")
    last_ts=$(get_last_timestamp "$jsonl_file")

    # Skip if we couldn't extract timestamps
    [[ -n "$first_ts" && -n "$last_ts" ]] || continue

    # Check if session overlaps with requested date range
    # Session overlaps if: session_start <= range_end AND session_end >= range_start
    if [[ "$first_ts" > "$END_TS" ]] || [[ "$last_ts" < "$START_TS" ]]; then
      continue
    fi

    file_bytes=$(wc -c < "$jsonl_file" | tr -d ' ')
    slug=$(get_session_slug "$jsonl_file")
    session_id=$(basename "$jsonl_file" .jsonl)

    if [[ "$first_entry" == "true" ]]; then
      first_entry=false
    else
      echo ","
    fi

    jq -n \
      --arg path "$jsonl_file" \
      --arg sessionId "$session_id" \
      --arg project "$project_name" \
      --arg projectPath "$project_path" \
      --arg slug "$slug" \
      --arg firstTimestamp "$first_ts" \
      --arg lastTimestamp "$last_ts" \
      --arg bytes "$file_bytes" \
      '{
        path: $path,
        sessionId: $sessionId,
        project: $project,
        projectPath: $projectPath,
        slug: $slug,
        firstTimestamp: $firstTimestamp,
        lastTimestamp: $lastTimestamp,
        bytes: ($bytes | tonumber)
      }'
  done
done

echo ""
echo "]"
```

**Step 2: Make executable and test**

```bash
chmod +x scripts/collect-sessions.sh
```

Run: `bash scripts/collect-sessions.sh 2026-03-05 2026-03-05`

Expected: JSON array with session entries from today. Verify:
- Valid JSON output (pipe through `jq .`)
- Timestamps are correct
- Project names decoded properly
- File paths are valid

**Step 3: Test edge cases**

Run with a date range that matches nothing:
```bash
bash scripts/collect-sessions.sh 2020-01-01 2020-01-02
```
Expected: `[]` (empty array)

Run with a wide range:
```bash
bash scripts/collect-sessions.sh 2026-03-01 2026-03-05 | jq 'length'
```
Expected: A count of all sessions from that week.

**Step 4: Commit**

```bash
git add scripts/collect-sessions.sh
git commit -m "feat: add collect-sessions.sh for JSONL date filtering"
```

---

### Task 3: Session Summary Schema

**Files:**
- Create: `skills/shared/session-summary-schema.md`

**Step 1: Write the schema document**

```markdown
# Session Summary Schema

This document defines the standardized intermediate format produced by per-session
extraction subagents. All lenses consume this format for cross-cutting analysis.

## Format

Each session summary is a markdown document with the following sections.
All sections are required unless marked optional.

### Metadata (Required)

| Field | Description |
|-------|-------------|
| Session ID | UUID from the JSONL filename |
| Session Slug | Human-readable name from system entries (if available) |
| Project | Project name |
| Project Path | Absolute filesystem path |
| Branch | Git branch during the session |
| Date | Start timestamp → End timestamp |
| Duration | Wall clock time (HH:MM) |
| Model | Primary model used (e.g., claude-opus-4-6) |
| Token Usage | Total input / output / cache tokens across all turns |
| Turn Count | N human turns, M assistant turns |

### What Happened (Required)

Comprehensive narrative of the session, scaled to its length and complexity:
- **Short sessions** (< 10 human turns): 2-4 sentences
- **Medium sessions** (10-30 human turns): 1-2 paragraphs
- **Long sessions** (30+ human turns): Structured with sub-headings for major phases

Captures the arc: what initiated the session, key milestones, direction changes, final state.

### Key Activities (Required)

Bulleted list of concrete accomplishments:
- Features built
- Bugs fixed
- Files created or significantly modified
- Decisions made
- PRs created, commits made

### Tools & Patterns (Required)

- **Files touched:** List of files read, written, or edited
- **Commands run:** Notable bash commands (not routine git/ls)
- **Subagents dispatched:** Count and brief purpose of each
- **Skills invoked:** List of skills used during the session

### Decisions & Rationale (Required)

Significant technical or design decisions made during the session, with the reasoning
behind them. Skip if no meaningful decisions were made (e.g., routine bug fixes).

### Blockers & Unresolved (Optional)

Anything attempted but abandoned, deferred to later, or left incomplete.
Include error messages or failure modes if relevant.

### Learnings & Insights (Optional)

Things discovered during the session:
- New patterns or techniques
- Surprising behavior or edge cases
- Reusable knowledge

### Lens-Specific Extraction (Optional)

Only present when the active lens provides extraction hints.
Format and content determined by the lens's extraction hints section.
```

**Step 2: Commit**

```bash
git add skills/shared/session-summary-schema.md
git commit -m "feat: add session summary schema for intermediate format"
```

---

### Task 4: Extraction Prompt

**Files:**
- Create: `skills/shared/extraction-prompt.md`

**Step 1: Write the extraction prompt**

This is the prompt given to each per-session subagent. It instructs the subagent on how to read a JSONL session file and produce the standardized summary.

```markdown
# Session Extraction Prompt

You are analyzing a single Claude Code session log (JSONL file) to produce a
standardized summary. Read the entire session file and produce a summary following
the Session Summary Schema.

## How to Read the Session

The file is JSONL — one JSON object per line. Key entry types:

- **`user` entries with string `message.content`**: Human messages (what the user said/asked)
- **`user` entries with array `message.content`**: Tool results (output from tools Claude called)
- **`assistant` entries**: Claude's responses, containing:
  - `{"type": "text", "text": "..."}` — response text
  - `{"type": "tool_use", "name": "...", "input": {...}}` — tool calls
  - `{"type": "thinking", "thinking": "..."}` — internal reasoning (skim for decision context)
- **`system` entries**: Metadata — look for `slug` (session name) and `durationMs` (turn timing)
- **`progress` entries**: Subagent dispatches and hook events (skim for context)
- **`file-history-snapshot` entries**: File change tracking (skip unless relevant)

## Reading Strategy

1. Read the JSONL file using the Read tool
2. Focus on `user` (string content) and `assistant` (text content) entries to understand the conversation
3. Scan `tool_use` entries to understand what actions were taken
4. Check `system` entries for the session slug and timing data
5. Aggregate `usage` fields from assistant entries for token totals
6. Count human turns (user entries with string content) and assistant turns

## Output Format

Produce the summary as markdown following the Session Summary Schema exactly.
Use the schema's section headers and include all required sections.
Scale the "What Happened" narrative to the session's complexity.

## Important

- Be factual — report what happened, don't editorialize
- Include specific file paths, function names, and error messages
- Capture the WHY behind decisions, not just the WHAT
- If the session was exploratory or brainstorming, capture the ideas discussed
- If the session ended mid-task, note what was left incomplete

{LENS_EXTRACTION_HINTS}
```

The `{LENS_EXTRACTION_HINTS}` placeholder is replaced at runtime with the lens's extraction hints section (if any), or removed if the lens has none.

**Step 2: Commit**

```bash
git add skills/shared/extraction-prompt.md
git commit -m "feat: add extraction prompt for per-session subagents"
```

---

### Task 5: Default Lenses

**Files:**
- Create: `lenses/standup.md`
- Create: `lenses/workflow-optimization.md`
- Create: `lenses/knowledge-extraction.md`

**Step 1: Write standup.md**

```markdown
---
name: standup
description: Daily standup summary — what was done, what's next, blockers
---

# Analysis Instructions

You have a collection of session summaries covering the specified date range.
Produce a standup-style report organized for quick scanning.

## Format

### Date Range
State the date range covered.

### What Got Done
Group by project. For each project:
- List concrete accomplishments (features, fixes, decisions)
- Note PRs created or merged
- Keep it factual and specific

### In Progress
- Work that was started but not completed
- Sessions that ended mid-task (reference the session slug)

### What's Next
Infer from:
- Unresolved items and deferred work
- Natural next steps from completed work
- Blockers that were identified but not resolved

### Blockers & Risks
- Recurring failures or error patterns
- Dependencies on external systems or people
- Sessions that ended in dead ends or frustration

### Knowledge Share
1-2 interesting discoveries or learnings worth sharing.
Keep it brief — link to the session slug for details.
```

**Step 2: Write workflow-optimization.md**

```markdown
---
name: workflow-optimization
description: Identify time sinks, inefficient patterns, and optimization opportunities
---

# Analysis Instructions

Analyze session summaries to identify workflow inefficiencies and optimization opportunities.
Focus on patterns across sessions, not individual incidents.

## Format

### Time Distribution
- How time was split across projects
- Longest sessions and what drove their length
- Sessions with high turn counts relative to output (potential inefficiency)

### Friction Points
- Tools or commands that failed repeatedly
- Topics where many turns were spent on clarification
- Permission issues, environment problems, or config struggles

### Repeated Patterns
- Similar work done across sessions that could be templated
- Multi-step processes performed manually that could be automated
- Information lookups that happen frequently

### Tool Usage Insights
- Most-used tools and how they were combined
- Subagent usage patterns — were they effective?
- Skills that were invoked vs could have been invoked

### Recommendations
Concrete suggestions for:
- Skills to create or modify
- Workflow changes to try
- Tools or configurations to adjust

## Extraction Hints

When summarizing each session, also capture:
- Turn count and estimated time spent
- Any repeated sequences of tool calls (3+ similar patterns)
- Moments where the user expressed frustration or had to repeat themselves
- Failed commands or tool calls and how they were resolved
```

**Step 3: Write knowledge-extraction.md**

```markdown
---
name: knowledge-extraction
description: Extract reusable learnings, patterns, and skill candidates
---

# Analysis Instructions

Analyze session summaries to extract actionable knowledge that can be
reused across projects and sessions.

## Format

### Technical Learnings
- New patterns, techniques, or APIs discovered
- Edge cases and their solutions
- Configuration insights or environment setup knowledge

### Architectural Patterns
- Design decisions made and their rationale
- Patterns that worked well (candidates for reuse)
- Anti-patterns discovered (things to avoid)

### Skill Candidates
For each candidate:
- **What it would do:** Brief description
- **Evidence:** Which sessions showed the need
- **Estimated value:** How often would this save time?

### Reusable Code & Snippets
- Helper functions or utilities written that could be extracted
- Configuration patterns worth templating
- Shell commands or pipelines worth saving

### Process Insights
- What worked well in the development process
- What could be improved about how Claude Code is used
- Communication patterns that were effective or ineffective

## Extraction Hints

When summarizing each session, also capture:
- Any time the user said "I wish...", "this should be...", or expressed a desire for automation
- Repeated sequences of tool calls that suggest a template-able workflow
- Novel combinations of tools or skills
- Debugging strategies that proved effective
- Code patterns that were written from scratch but exist in libraries
```

**Step 4: Commit**

```bash
git add lenses/standup.md lenses/workflow-optimization.md lenses/knowledge-extraction.md
git commit -m "feat: add default lenses — standup, workflow-optimization, knowledge-extraction"
```

---

### Task 6: Install and Uninstall Scripts

**Files:**
- Create: `scripts/install.sh`
- Create: `scripts/uninstall.sh`

**Step 1: Write install.sh**

```bash
#!/usr/bin/env bash
# ABOUTME: Installs cc-review default lenses and creates user directories.
# ABOUTME: Safe to re-run — does not overwrite existing user lenses.

set -euo pipefail

CC_REVIEW_DIR="${HOME}/.claude/cc-review"
LENSES_DIR="${CC_REVIEW_DIR}/lenses"
REPORTS_DIR="${CC_REVIEW_DIR}/reports"

# Find the plugin's lenses directory (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_LENSES_DIR="${SCRIPT_DIR}/../lenses"

echo "Installing cc-review..."

# Create directories
mkdir -p "$LENSES_DIR"
mkdir -p "$REPORTS_DIR"
echo "  Created ${LENSES_DIR}"
echo "  Created ${REPORTS_DIR}"

# Copy default lenses (skip existing to preserve customizations)
if [[ -d "$PLUGIN_LENSES_DIR" ]]; then
  for lens_file in "$PLUGIN_LENSES_DIR"/*.md; do
    [[ -f "$lens_file" ]] || continue
    lens_name=$(basename "$lens_file")
    if [[ -f "${LENSES_DIR}/${lens_name}" ]]; then
      echo "  Skipped ${lens_name} (already exists, preserving customizations)"
    else
      cp "$lens_file" "${LENSES_DIR}/${lens_name}"
      echo "  Installed ${lens_name}"
    fi
  done
else
  echo "  Warning: No default lenses found at ${PLUGIN_LENSES_DIR}"
fi

echo ""
echo "Installation complete!"
echo "  Lenses: ${LENSES_DIR}"
echo "  Reports: ${REPORTS_DIR}"
echo ""
echo "Usage:"
echo "  Interactive: /cc-review today standup"
echo "  Headless:    claude -p \"use the cc-review skill for today with the standup lens\""
```

**Step 2: Write uninstall.sh**

```bash
#!/usr/bin/env bash
# ABOUTME: Removes cc-review user directories after confirmation.
# ABOUTME: Does not remove the plugin itself, only user-generated data and config.

set -euo pipefail

CC_REVIEW_DIR="${HOME}/.claude/cc-review"

if [[ ! -d "$CC_REVIEW_DIR" ]]; then
  echo "Nothing to uninstall — ${CC_REVIEW_DIR} does not exist."
  exit 0
fi

echo "This will remove:"
echo "  ${CC_REVIEW_DIR}/lenses/ (your lens files, including customizations)"
echo "  ${CC_REVIEW_DIR}/reports/ (all generated reports)"
echo ""
read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf "$CC_REVIEW_DIR"
  echo "Removed ${CC_REVIEW_DIR}"
else
  echo "Cancelled."
fi
```

**Step 3: Make executable and commit**

```bash
chmod +x scripts/install.sh scripts/uninstall.sh
git add scripts/install.sh scripts/uninstall.sh
git commit -m "feat: add install and uninstall scripts for user directory setup"
```

---

### Task 7: Main Skill (SKILL.md)

This is the orchestrator — the core of the plugin. It tells Claude how to run the full pipeline.

**Files:**
- Create: `skills/SKILL.md`

**Step 1: Write SKILL.md**

```markdown
---
name: cc-review
description: Analyze Claude Code session logs through configurable lenses. Use when asked to review, summarize, or analyze session history. Accepts date-range and lens-name as arguments.
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

Where `<plugin-base-dir>` is the directory containing this skill (shown in the skill
loading message).

## Pipeline

Follow these phases in order. Do not skip phases.

### Phase 0: Parse Arguments and Validate

1. Parse the arguments string to extract date-range and lens-name
2. Resolve the date range to start and end dates (YYYY-MM-DD format):
   - `today` → today's date for both start and end
   - `yesterday` → yesterday's date for both
   - `last-week` → 7 days ago through today
   - `last-month` → 30 days ago through today
   - `last-N-days` → N days ago through today
   - `YYYY-MM-DD` → that date for both start and end
   - `YYYY-MM-DD:YYYY-MM-DD` → start and end as given
3. If no lens specified, use `standup` as default
4. Verify the lens file exists at `~/.claude/cc-review/lenses/<lens-name>.md`
   - If not found, list available lenses and stop
5. Verify `~/.claude/cc-review/lenses/` exists
   - If not found, tell the user to run the install script and stop

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
3. If it does, extract that section — it will be appended to the extraction prompt
   for each subagent

### Phase 3: Extract Session Summaries (Parallel Subagents)

For each session in the manifest, dispatch a subagent to produce a session summary.

**Subagent instructions:**

Each subagent should:
1. Read the JSONL file at the path from the manifest
2. Follow the extraction prompt at `<plugin-base-dir>/skills/shared/extraction-prompt.md`
3. Follow the session summary schema at `<plugin-base-dir>/skills/shared/session-summary-schema.md`
4. If the lens has extraction hints, append them to the extraction prompt
   (replace the `{LENS_EXTRACTION_HINTS}` placeholder)
5. Return the session summary as markdown text

**Batching:**
- Dispatch subagents in parallel batches of up to 5
- Wait for each batch to complete before starting the next
- Use a large-context model for sessions over 500KB

**Error handling:**
- If a subagent fails, log the error and continue with remaining sessions
- Include a note in the final report about any failed extractions

Report progress: "Summarized N/M sessions..."

### Phase 4: Cross-Cutting Analysis

Once all session summaries are collected:

1. Read the lens file's `# Analysis Instructions` section
2. Combine all session summaries into a single context
3. Apply the lens analysis instructions to produce the final report
4. The report should follow the format specified in the lens file

### Phase 5: Write Report

1. Determine the output path: `~/.claude/cc-review/reports/<date-range>/<lens-name>.md`
   - For single dates: `YYYY-MM-DD/lens-name.md`
   - For ranges: `YYYY-MM-DD_to_YYYY-MM-DD/lens-name.md`
2. Create the directory if needed
3. Write the report file
4. Report to the user: "Report written to <path>"
5. Show a brief preview of the report (first 20 lines or the executive summary)
```

**Step 2: Commit**

```bash
git add skills/SKILL.md
git commit -m "feat: add main SKILL.md orchestrator for cc-review pipeline"
```

---

### Task 8: End-to-End Test

**Files:** None created — this is a manual validation task.

**Step 1: Run the install script**

```bash
bash scripts/install.sh
```

Expected: Creates `~/.claude/cc-review/lenses/` and `~/.claude/cc-review/reports/`, copies 3 default lenses.

**Step 2: Verify collect-sessions.sh works**

```bash
bash scripts/collect-sessions.sh 2026-03-05 2026-03-05 | jq .
```

Expected: Valid JSON manifest with today's sessions.

**Step 3: Test the skill interactively**

In a new Claude Code session in this project directory:

```
/cc-review today standup
```

Expected: The skill runs the full pipeline — collects sessions, dispatches subagents, produces a standup report, writes it to `~/.claude/cc-review/reports/2026-03-05/standup.md`.

**Step 4: Verify the report**

Read the generated report and verify:
- It covers the right sessions
- The standup format is followed
- Project grouping works
- Content is factual and useful

**Step 5: Test error cases**

- `/cc-review today nonexistent-lens` → should list available lenses
- `/cc-review 2020-01-01 standup` → should report no sessions found

**Step 6: Test headless mode**

```bash
claude -p --dangerously-skip-permissions \
  "use the cc-review skill for today with the standup lens"
```

Expected: Report generated without interactive prompts.

**Step 7: Commit any fixes from testing**

```bash
git add -A
git commit -m "fix: adjustments from end-to-end testing"
```

---

## Task Summary

| Task | Description | Dependencies |
|------|-------------|-------------|
| 1 | Plugin scaffold | None |
| 2 | collect-sessions.sh | None |
| 3 | Session summary schema | None |
| 4 | Extraction prompt | Task 3 |
| 5 | Default lenses | None |
| 6 | Install/uninstall scripts | Task 5 |
| 7 | Main SKILL.md | Tasks 2, 3, 4, 5 |
| 8 | End-to-end test | All above |

Tasks 1-3 and 5 can be done in parallel. Task 4 depends on 3. Task 6 depends on 5. Task 7 depends on 2, 3, 4, 5. Task 8 depends on all.
