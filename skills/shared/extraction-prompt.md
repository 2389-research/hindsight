<!-- ABOUTME: Prompt template given to per-session extraction subagents. -->
<!-- ABOUTME: Instructs how to read session data from the assigned source and produce standardized summaries. -->

# Session Extraction Prompt

You are analyzing a single Claude Code session to produce a standardized summary
following the Session Summary Schema.

## How to Read the Session

Your assigned source is **{source}**. The CLI contract for this source is:

{SOURCE_CLI_CONTRACT}

Follow that contract: probe (already verified by parent) → show metadata → export transcript.

Read the exported transcript with the Read tool, paginating with offset/limit for long sessions.

## Reading Strategy

1. Get the metadata (from `show`)
2. Get the full transcript (from `export`)
3. Skim user turns first for the arc, then sample assistant turns at decision points rather than reading every turn
4. For long sessions (100+ turns): focus on user turns for narrative arc; sample assistant turns at key decisions

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
- Use precise language, not subjective characterizations from the session. If
  the session says "pixel-perfect match" but also notes a cosmetic difference,
  report both facts rather than repeating the characterization uncaveated.
- Include specific file paths, function names, and error messages
- Capture the WHY behind decisions, not just the WHAT
- If the session creates or references a git repository, capture the org/repo
  path (e.g., `2389-research/jeff`, `detour1999/postkeeper`) so downstream
  reports can link to it.
- If the session was exploratory or brainstorming, capture the ideas discussed
- If the session ended mid-task, note what was left incomplete

{LENS_EXTRACTION_HINTS}
