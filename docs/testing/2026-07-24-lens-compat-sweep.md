# Lens compatibility sweep — 2026-07-24

Verified after refactor to dual-source Phase 1 (Tasks 1-6 on branch
`feature/agentview-source`).

## Method

Structural verification only — a subagent cannot invoke `/hindsight`
end-to-end. For each built-in lens: (1) reads well as markdown,
(2) frontmatter intact (`name`, `description`, `version`),
(3) analysis instructions reference only session-summary-schema
fields, (4) no source-specific field leaks (ccvault-only fields like
`source_file` or agentsview-only fields like `health_score`).

Source-specific field names checked by grep across `lenses/`:

- **ccvault-only:** `source_file`, `has_error`, `has_subagent`,
  `project_id`, `input_tokens`, `output_tokens`, `cache_read_tokens`,
  `cache_write_tokens`, `git_branch`, `turn_count`
- **agentsview-only:** `health_score`, `health_grade`, `health_penalties`,
  `health_score_basis`, `outcome`, `outcome_confidence`, `edit_churn_count`,
  `compaction_count`, `secret_leak_count`, `tool_failure_signal_count`,
  `tool_retry_count`
- **Source-adjacent:** `nanoclaw`, `cwd`, `machine`, `agentsview`, `ccvault`
- **Ambiguous field-name usage:** `agent:`, `outcome` (checked in context —
  every hit was ordinary English prose, e.g. "the agent" as AI-assistant
  or "what outcome it prevents", not the agentsview `agent` field)

## Scope note

The plan text listed 7 built-in lenses including `intent-retro`, but
`lenses/` currently ships 6 files: `agent-autonomy.md`,
`content-mining.md`, `knowledge-extraction.md`, `skill-review.md`,
`standup.md`, `workflow-optimization.md`. There is no `intent-retro.md`
on `feature/agentview-source`; a `feature/intent-retro-lens` branch
exists but is not merged. This sweep covers the 6 lenses actually
present on the current branch.

## Results

| Lens | Reads well | Frontmatter | Schema fields | Source leaks | Verdict |
|---|---|---|---|---|---|
| standup | yes | yes | yes | none | pass |
| knowledge-extraction | yes | yes | yes | none | pass |
| workflow-optimization | yes | yes | yes | none | pass |
| agent-autonomy | yes | yes | yes | none | pass |
| content-mining | yes | yes | yes | none | pass |
| skill-review | yes | yes | yes | none | pass |

### Per-lens notes

- **standup** (`version: 7`): References project name, description, repo
  URL, PR URLs, date range — all schema-derivable. Extraction hints ask
  for git-remote/GitHub URL and collaboration context. Clean.
- **knowledge-extraction** (`version: 4`): References project and
  session content only. Extraction hints ask for debugging stories,
  edge cases, version numbers — all narrative, no source fields. Clean.
- **workflow-optimization** (`version: 4`): References turn count,
  time distribution, tool calls, correction patterns — all schema
  fields or narrative. "Turn count" and "estimated time spent" appear
  in extraction hints; both are canonical session-summary fields.
  Clean.
- **agent-autonomy** (`version: 3`): References human messages, agent
  messages, session IDs, project context. All prose usage of "agent"
  refers to the AI assistant, not the agentsview `agent` field. Clean.
- **content-mining** (`version: 4`): References project names,
  narrative moments, before/after metrics. No source fields. Clean.
- **skill-review** (`version: 2`): References skills invoked, session
  ID, project, user messages, agent actions. "Skills invoked" is the
  canonical session-summary field name from
  `skills/shared/session-summary-schema.md` (Tools & Patterns section).
  Clean.

## Interpretation

The source layer abstraction is honest: no built-in lens reaches through
the session-summary schema to source-specific fields. Adding agentsview
as an alternative source does not require any lens change. Every field
a lens reads is defined in
`skills/shared/session-summary-schema.md`, which is source-agnostic by
construction (the extraction subagent normalizes both ccvault and
agentsview transcripts into the same shape).

## Follow-up

Full behavioral verification (running each lens against a real date
range end-to-end and comparing outputs) is a Task 8 manual smoke test.
