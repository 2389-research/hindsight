<!-- ABOUTME: Lens for daily standup summaries — what was done, what's next, blockers. -->
<!-- ABOUTME: Groups activity by project for quick scanning. -->

---
name: standup
description: Daily standup summary — what was done, what's next, blockers
version: 7
---

# Analysis Instructions

Produce a standup-style report organized by project for quick scanning.
Outcomes, not process.

- Describe what was accomplished, not how it was implemented. Component names,
  function signatures, and CSS selectors belong in commit messages, not standups.
- Exclude ideation and brainstorming from all sections
- Omit projects with no specific activity for the date range
- Expand acronyms only when a reader familiar with software development would
  not recognize the term in context. Use judgment — TUI, API, PR, CSS, JSON
  need no expansion; a project-specific or uncommon acronym like MCP or SPA
  likely does on first use.

## Format

The report is organized by project, not by status category. Each project
is a self-contained block that can be read independently.

Use `##` for each project heading. Include the project description and repo
link on the heading — e.g., `## jeff — Rust-based TUI email client
([2389-research/jeff](https://github.com/2389-research/jeff))`.

No trailing periods on bullets. Every accomplishment bullet must start with
a past-tense verb. Every next-step bullet must start with an infinitive verb.
PR references must also start with a verb — e.g., "Created PR #69: https://..."
not "PR: https://...".

When two projects share a data pipeline or dependency, note the connection
on first mention — e.g., "Reimported 40 Goodreads posts with corrected
data from upstream PostKeeper fix".

## Date Range
State the date range covered at the top of the report.

## Per-Project Block

Each project block has this structure:

```
## project-name — description ([org/repo](url))
Status: On track

- Accomplishment bullet (past tense)
- Another accomplishment

**Next:** What comes next (infinitive tense)
```

**Status line rules:**
- Use plain text for healthy status: `Status: On track`
- Use **bold** for anything that needs attention: `**Status: Blocked — reason**`
  or `**Status: At risk — reason**`
- Valid statuses: `On track`, `Blocked — <reason>`, `At risk — <reason>`,
  `In progress — <context>`, `Stalled — <reason>`
- If work is in progress with no issues, use `On track`

**Accomplishments:** Past-tense bullets listing what got done. Keep to outcomes.
Include PRs with full URLs.

**Next line:** A single `**Next:**` line at the end with comma-separated next
steps in infinitive tense. If nothing is next, omit the line. Do not list work
that is already complete.

## Project Ordering

Order projects by attention needed: blocked/at-risk projects first, then
on-track projects. Within each group, order by volume of activity.

## Extraction Hints

When reading each session, also capture:
- **Repository URL**: If the session references a git remote, org/repo path, or
  GitHub URL, include it in the summary metadata so the report can link to it.
- **Collaboration context**: Note whether work appears solo or collaborative
  (e.g., PR reviews from others, pair programming, handoffs mentioned).
