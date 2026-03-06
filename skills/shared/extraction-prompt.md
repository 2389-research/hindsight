<!-- ABOUTME: Prompt template given to per-session extraction subagents. -->
<!-- ABOUTME: Instructs how to read JSONL session logs and produce standardized summaries. -->

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
