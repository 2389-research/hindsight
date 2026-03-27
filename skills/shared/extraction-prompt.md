<!-- ABOUTME: Prompt template given to per-session extraction subagents. -->
<!-- ABOUTME: Instructs how to read session data via ccvault MCP tools and produce standardized summaries. -->

# Session Extraction Prompt

You are analyzing a single Claude Code session to produce a standardized summary.
Use ccvault's MCP tools to access the session data, then produce a summary following
the Session Summary Schema.

## How to Read the Session

Use ccvault's MCP tools in this order:

1. **`get_session_summary`** — Start here. Returns metadata (project, model, dates,
   git branch), turn counts by type, token usage, top 10 tools used, and first/last
   user messages (500 chars each). This gives you the skeleton of the summary.

2. **`get_turns`** — Paginate through session content. Each turn is truncated to
   1000 chars. Key parameters:
   - `type: "user"` — human messages only (understand what was asked/directed)
   - `type: "assistant"` — Claude's responses and tool calls
   - `limit: 50`, incrementing `offset` to paginate
   - Check `has_more` to know when to stop

3. **`search_conversations`** — Use targeted searches within the session's project
   to find specific content (error messages, decisions, key phrases).

## Reading Strategy

1. Call `get_session_summary` to get the full metadata picture
2. Page through `get_turns` with `type: "user"` to understand the conversation arc
3. Page through `get_turns` with `type: "assistant"` to capture decisions, tool usage,
   and key responses
4. For long sessions (100+ turns), focus on user turns for the narrative arc, then
   sample assistant turns at key decision points rather than reading every turn
5. Use the metadata (tools used, turn counts, token usage) to fill in the quantitative
   sections of the summary

## Output Format

Produce the summary as markdown following the Session Summary Schema exactly.
Use the schema's section headers and include all required sections.
Scale the "What Happened" narrative to the session's complexity.

## Metadata Extraction Tips

- **Session Slug**: Look for the human-readable session name in system entries or
  the first user message. If `get_session_summary` returns a slug field, use it.
  Otherwise, leave blank rather than fabricating one.
- **Duration**: Compute from the start and end timestamps returned by
  `get_session_summary`. Format as HH:MM wall clock time.
- **Project Description**: Write a one-line description of what this project is,
  inferred from the session content (e.g., "Android email client" or
  "automotive parts catalog"). This helps report readers who aren't familiar
  with the project name.
- **PR URLs**: When the session creates or references a PR, capture the full URL
  (e.g., from `gh pr create` output or browser links in messages), not just the
  PR number. If only a number is available, include the repo context so the
  aggregation agent can construct a link.

## Important

- Be factual — report what happened, don't editorialize
- Include specific file paths, function names, and error messages
- Capture the WHY behind decisions, not just the WHAT
- If the session was exploratory or brainstorming, capture the ideas discussed
- If the session ended mid-task, note what was left incomplete

{LENS_EXTRACTION_HINTS}
