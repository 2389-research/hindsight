<!-- ABOUTME: Lens for extracting reusable learnings, patterns, and skill evolution opportunities. -->
<!-- ABOUTME: Identifies both new skill candidates and refinements to existing skills. -->

---
name: knowledge-extraction
description: Extract reusable learnings, patterns, and skill candidates
version: 1
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

### Skill Evolution

#### Existing Skill Refinements
For skills that were used during the sessions but showed friction, gaps, or missed potential:
- **Skill name:** Which skill
- **What worked:** What the skill did well
- **What fell short:** Specific friction points, gaps, or missed edge cases observed
- **Suggested change:** Concrete improvement (new section, updated flowchart, additional triggers, etc.)
- **Evidence:** Which sessions revealed this

#### New Skill Candidates
For workflows or patterns that don't have a skill yet but should:
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
- Skills that were invoked but caused friction, required workarounds, or missed edge cases
- Workflows where a skill should have been used but wasn't (missed triggers)
- User corrections that suggest a skill's guidance is incomplete or wrong
