<!-- ABOUTME: Lens for mining session data to find blog post, social media, and announcement opportunities. -->
<!-- ABOUTME: Surfaces content-worthy moments and packages them with title, pitch, format, and audience. -->

---
name: content-mining
description: Surface blog posts, social media content, and announcements from session activity
version: 2
---

# Analysis Instructions

Analyze session summaries to find moments worth writing about publicly.
For each content opportunity, package it as a publishable pitch.

**What makes something content-worthy:**
- A problem solved that others would google
- A non-obvious debugging story with a satisfying resolution
- Something shipped that reached a usable state
- An architectural pattern or technique worth sharing
- A deep thought or realization about tooling, process, or craft
- A before/after transformation (refactor, performance, DX improvement)

**What is NOT content-worthy:**
- Routine maintenance (dependency updates, config changes)
- Work that's too project-specific to generalize
- Incomplete investigations that didn't reach a conclusion

**Framing principles:**
- Lead with the insight, not the tool. "The ellipse that fixes tire pressure math"
  beats "I used AI to build a tire calculator." The story is the problem and solution,
  not how it was built.
- Aim for format diversity across the report — if most entries are blog posts,
  consider whether some would work better as tweet threads, short posts, or demos.

## Format

### Top Picks

Start with the 3 highest-value opportunities. For each, explain in one sentence
why it ranks above the rest.

### Content Opportunities

For each opportunity, provide:

#### [Suggested Title]
- **Format**: blog post / tweet thread / short post / product announcement / demo video / TIL
- **Audience**: developer community / personal brand / product users
- **Effort**: quick (1-2 hours) / medium (half day) / deep (multi-day research)
- **Pitch**: 2-3 sentences explaining the content angle and why it's interesting
- **Key hook**: the one sentence that would make someone click or keep reading
- **Key example**: a code snippet, command, metric, or before/after that anchors the piece
- **Risk**: any editorial concerns — too niche, could be misread, reveals internal details
- **Source sessions**: which sessions this draws from

Order by estimated audience interest (most compelling first).

### Quick Hits

Short-form content that doesn't need a full write-up — single observations,
one-liners, screenshots, or TILs that work as standalone social posts.
Format as a bulleted list with the post text and source session.

Note: if a Quick Hit has broader appeal than a main Content Opportunity,
call that out — some of the best social content is a single surprising fact.

### Themes

Cross-cutting patterns that connect multiple content opportunities. These
are the "meta" stories — what do the individual pieces add up to? Useful
for talks, essays, or series framing.

## Extraction Hints

When summarizing each session, also capture:
- Debugging stories with non-obvious root causes
- "Aha" moments where a surprising approach worked
- Before/after metrics (performance, line count, test count, time saved)
- Tools or techniques used in unexpected combinations
- User reactions that suggest genuine surprise or satisfaction
- Anything the user explicitly said was interesting, cool, or worth sharing
- New projects or features that reached a demo-able or usable state
- Problems that took multiple attempts to solve (the struggle is the story)
- Key code snippets, commands, or configuration that could anchor a blog post
