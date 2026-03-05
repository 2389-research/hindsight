# CC Review — Session Log Analyzer Design

## Overview

A Claude Code plugin that analyzes session logs across projects, producing configurable reports through a modular lens system. Runs interactively via skill invocation or headless via `claude -p` for cron automation.

## Architecture

**Pure skill plugin** with a thin bash script for JSONL date filtering. All intelligence lives in skill prompts and lens files.

### Plugin Structure

```
cc-review/                              # Plugin repo
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── SKILL.md                        # Main orchestrator skill
│   └── shared/
│       ├── session-summary-schema.md   # Standard intermediate format spec
│       └── extraction-prompt.md        # Base prompt for phase 2 subagents
├── lenses/                             # Bundled default lenses (copied on install)
│   ├── standup.md
│   ├── workflow-optimization.md
│   └── knowledge-extraction.md
├── scripts/
│   ├── install.sh                      # Copies default lenses, creates user dirs
│   ├── uninstall.sh                    # Removes user dirs
│   └── collect-sessions.sh            # Filters JSONL files by date range
├── CLAUDE.md
└── README.md
```

### User-Owned Directories

```
~/.claude/cc-review/                    # User-owned config + output
├── lenses/                             # User's lens library
│   ├── standup.md                      # Installed from defaults, user-editable
│   ├── workflow-optimization.md
│   ├── knowledge-extraction.md
│   └── my-custom-lens.md              # User-added lenses
└── reports/                            # Generated reports
    └── YYYY-MM-DD/
        └── lens-name.md
```

## Pipeline

```
Invocation
    │
    ▼
Phase 1: collect-sessions.sh
    • Scans ~/.claude/projects/*/
    • Filters JSONL files by date range (reads first/last line timestamps)
    • Outputs manifest JSON: [{path, project, slug, firstTimestamp, lastTimestamp, bytes}]
    │
    ▼
Phase 2: Fan-out per-session subagents (parallel)
    • One subagent per session file
    • Uses extraction-prompt.md + optional lens extraction hints
    • Produces standardized session summary (see schema below)
    • Uses large-context model for big sessions
    • Batched 5-10 at a time to avoid overload
    │
    ▼
Phase 3: Fan-in cross-cutting analysis
    • Loads selected lens .md file
    • Receives all session summaries
    • Produces final report per lens instructions
    │
    ▼
Phase 4: Write report
    • Writes to ~/.claude/cc-review/reports/YYYY-MM-DD/lens-name.md
```

## Session Summary Schema (Intermediate Format)

Each Phase 2 subagent produces this standardized format:

```markdown
# Session Summary

## Metadata
- **Session ID:** {uuid}
- **Session Slug:** {human-readable-name}
- **Project:** {project name}
- **Project Path:** {absolute path}
- **Branch:** {git branch}
- **Date:** {start} → {end}
- **Duration:** {wall clock time}
- **Model:** {primary model used}
- **Token Usage:** {total input/output/cache tokens}
- **Turn Count:** {human turns} human, {assistant turns} assistant

## What Happened
{Comprehensive narrative scaled to session length and complexity.
 Short sessions (< 10 turns): 2-4 sentences.
 Medium sessions (10-30 turns): 1-2 paragraphs.
 Long sessions (30+ turns): structured with sub-sections for major phases.
 Captures the arc: what started the session, key milestones, pivots, where things ended.}

## Key Activities
- {bulleted list: features built, bugs fixed, files created/modified, decisions made}

## Tools & Patterns
- **Files touched:** {list of files read/written/edited}
- **Commands run:** {notable bash commands}
- **Subagents dispatched:** {count and purposes}
- **Skills invoked:** {list of skills used}

## Decisions & Rationale
- {significant technical or design decisions with reasoning}

## Blockers & Unresolved
- {anything attempted but didn't work, or was deferred}

## Learnings & Insights
- {things discovered, patterns recognized, "aha" moments}

## Lens-Specific Extraction
{optional — only present if the active lens provided extraction hints}
```

## Lens Format

Each lens is a markdown file with YAML frontmatter:

```markdown
---
name: lens-name
description: What this lens does
---

# Analysis Instructions

{Prompt for the cross-cutting analysis phase}

## Extraction Hints (Optional)

{Appended to per-session extraction prompt for lens-specific data capture}
```

### Default Lenses

**standup.md** — Daily standup: what was done (grouped by project), what's next, blockers & risks, knowledge share.

**workflow-optimization.md** — Where time is lost, inefficient patterns, repeated mistakes, tool usage insights.

**knowledge-extraction.md** — Reusable patterns, skill candidates (automation opportunities), tool & workflow insights. Extraction hints capture "I wish..." statements and repeated tool call sequences.

## Invocation

### Interactive (skill)
```
/cc-review today standup
/cc-review last-week knowledge-extraction
/cc-review 2026-03-01:2026-03-05 workflow-optimization
/cc-review yesterday                    # runs default lens (standup)
```

### Headless (cron)
```bash
claude -p --dangerously-skip-permissions \
  "use the cc-review skill for today with the standup lens"
```

### Date Range Formats
- `today`, `yesterday`
- `last-week`, `last-month`
- `last-N-days` (e.g., `last-7-days`)
- `YYYY-MM-DD` (single day)
- `YYYY-MM-DD:YYYY-MM-DD` (explicit range)

### Default Behavior
- No lens specified → runs configurable default (ships as `standup`)
- No date specified → defaults to `today`

## collect-sessions.sh

Pure bash script. Given a date range:

1. Walks `~/.claude/projects/*/`
2. For each `*.jsonl` file, reads first and last line to extract timestamps
3. Filters files whose session overlaps the requested date range
4. Extracts project name from directory path
5. Extracts session slug from `system` entries (if quick to find)
6. Outputs JSON manifest to stdout:

```json
[
  {
    "path": "/Users/dylanr/.claude/projects/-Users-dylanr-work-2389-boba/abc123.jsonl",
    "project": "boba",
    "projectPath": "/Users/dylanr/work/2389/boba",
    "slug": "mutable-fluttering-salamander",
    "firstTimestamp": "2026-03-05T09:00:00Z",
    "lastTimestamp": "2026-03-05T11:30:00Z",
    "bytes": 245000
  }
]
```

## Install / Uninstall

**install.sh:**
1. Creates `~/.claude/cc-review/lenses/` and `~/.claude/cc-review/reports/`
2. Copies default lenses from plugin's `lenses/` directory to user directory
3. Does NOT overwrite existing user lenses (preserves customizations)

**uninstall.sh:**
1. Optionally removes `~/.claude/cc-review/` (with confirmation)

## Error Handling

- **No sessions in range:** Clear message, no empty report generated
- **Very large sessions:** Subagent uses large-context model; extraction prompt instructs chunked reading if needed
- **Many sessions (50+):** Batched subagent dispatch, 5-10 at a time
- **Lens not found:** Error with list of available lenses
- **First run / no lenses:** Detects missing user dir, prompts to run install
- **JSONL parse errors:** Skip malformed files with warning in report

## Data Sources

Session logs are stored at `~/.claude/projects/` as JSONL files. Each line is a JSON object with fields:

- `type`: user | assistant | progress | system | file-history-snapshot
- `timestamp`: ISO 8601
- `message.content`: conversation content (text, tool_use, tool_result, thinking)
- `usage`: token counts per assistant turn
- `cwd`, `gitBranch`, `version`, `sessionId`

Additional context available at:
- `~/.claude/todos/` — per-session task lists
- `~/.claude/history.jsonl` — global command history
- `~/.claude/plans/` — named plan documents

## Future Considerations

- Dashboard/web UI for browsing reports
- Trend analysis across longer time periods
- Integration with team communication tools (Slack, etc.)
- Cost tracking and optimization recommendations
- Session tagging/categorization for better filtering
