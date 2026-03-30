<!-- ABOUTME: Lens for mining session data to find blog post, social media, and announcement opportunities. -->
<!-- ABOUTME: Surfaces content-worthy moments and packages them with title, pitch, format, and audience. -->

---
name: content-mining
description: Surface blog posts, social media content, and announcements from session activity
version: 3
---

# Analysis Instructions

Find moments worth writing about publicly. Package each as a publishable pitch.
Lead with the insight, not the tool — the story is the problem and solution.

Content-worthy: problems others would google, non-obvious debugging stories,
things that shipped, architectural patterns, deep thoughts on craft, before/after
transformations. NOT content-worthy: routine maintenance, project-specific details,
incomplete investigations. Aim for format diversity across the report.

Use `##` for sections, `###` for individual content opportunities.

## Top Picks

The 3 highest-value opportunities. One sentence each on why they rank above the rest.

## Content Opportunities

For each opportunity:

### [Suggested Title]
- **Format**: blog post / tweet thread / short post / product announcement / demo video / TIL
- **Audience**: developer community / personal brand / product users
- **Effort**: quick (1-2 hours) / medium (half day) / deep (multi-day research)
- **Pitch**: 2-3 sentences on the content angle and why it's interesting
- **Key hook**: the one sentence that would make someone click
- **Key example**: a code snippet, command, metric, or before/after that anchors the piece
- **Risk**: editorial concerns — too niche, could be misread, reveals internal details
- **Source sessions**: which sessions this draws from

Order by estimated audience interest (most compelling first).

## Quick Hits

Short-form content that doesn't need a full write-up — single observations,
one-liners, screenshots, or TILs that work as standalone social posts.
Bulleted list with the post text and source session.

If a Quick Hit has broader appeal than a main Content Opportunity, call that out.

## Themes

Cross-cutting patterns that connect multiple content opportunities — the "meta"
stories. Useful for talks, essays, or series framing.

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
