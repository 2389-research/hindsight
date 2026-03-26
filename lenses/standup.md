<!-- ABOUTME: Lens for daily standup summaries — what was done, what's next, blockers. -->
<!-- ABOUTME: Groups activity by project for quick scanning. -->

---
name: standup
description: Daily standup summary — what was done, what's next, blockers
version: 2
---

# Analysis Instructions

You have a collection of session summaries covering the specified date range.
Produce a standup-style report organized for quick scanning.

**Content principles:**
- Prefer outcomes over implementation detail. "Rewrote auth module, 14 tests passing"
  is better than "deleted 8,888 lines, refactored app.rs monolith into 130-line module."
- Exclude ideation and roadmap brainstorming from accomplishments. Only list work
  that was actually done, not future plans that were discussed.
- Every bullet should answer "what changed?" not "what was the process?"

## Format

### Date Range
State the date range covered.

### Blockers & Risks
Lead with blockers — readers need these first.
- Recurring failures or error patterns
- Dependencies on external systems or people
- Sessions that ended in dead ends or frustration

### What Got Done
Group by project using ### sub-headings. For each project:
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

## Formatting Guide

- Use `###` sub-headings for project grouping in all sections (not bold text in bullets)
- Start each bullet with a past-tense verb phrase ("Added...", "Fixed...", "Merged...")
- No trailing periods on bullets
- Use em dashes (—) for inline asides, not parenthetical nesting
