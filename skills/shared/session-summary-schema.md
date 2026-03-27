<!-- ABOUTME: Defines the standardized intermediate format for per-session summaries. -->
<!-- ABOUTME: All lenses consume this format for cross-cutting analysis. -->

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
| Project Description | One-line description of what this project is, inferred from session content |
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
- PRs created (include full URL if available, not just number), commits made

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
