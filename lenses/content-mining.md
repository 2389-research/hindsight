<!-- ABOUTME: Lens for mining session data to find blog post, social media, and announcement opportunities. -->
<!-- ABOUTME: Surfaces content-worthy moments and packages them with title, pitch, format, and audience. -->

---
name: content-mining
description: Surface blog posts, social media content, and announcements from session activity
version: 4
---

# Analysis Instructions

Find moments worth writing about publicly. Lead with the insight, not the tool —
the story is the problem and solution, not the output volume.

The report has three sections: Long Form, Short Form, and Themes. Prioritize
signal over completeness — fewer strong ideas beat many weak ones.

Use `##` for sections, `###` for individual items.

## Long Form

Blog posts, tutorials, essays, or talks that need real writing effort.

**Novelty threshold:** Only include ideas where the insight is genuinely
interesting or useful to someone outside the author's immediate context. Ask:
"Would a developer who doesn't know this project care?" If not, skip it.
Routine accomplishments, volume metrics (lines deleted, tests passing, docs
synced), and "I built X in Y hours" stories do not clear the bar unless there
is a non-obvious insight, a surprising failure, or a transferable technique
underneath. Prefer the debugging journey over the trophy.

Each long-form item is a lightweight pitch — just enough to decide whether
to pursue it. If the idea moves forward, everything gets relitigated anyway.

```text
### [Suggested Title]
[One-line pitch — the idea in a single sentence]

**Why it's interesting**: 1-2 sentences on what makes this worth reading —
the non-obvious insight, the surprising failure, or the transferable lesson.
**Audience**: short, vibes-based — e.g., "standards nerds", "Android devs
who've been burned by Hilt scoping", "anyone who's stared at a slow migration"
**⚠ CAUTION**: [only if there is a real brand safety, confidentiality, or
accuracy concern — omit entirely if none]
```

Do not include source session IDs. Reference projects by name if needed.

Order by how interesting the insight is, not by output volume.

## Short Form

Standalone social posts, TILs, and one-liners ready to copy-paste into a
scheduling tool. Each bullet is the post text itself — a complete thought,
not a teaser for a longer piece.

Bulleted list. Max 2 bullets from any single session to prevent over-indexing.

If a short-form item has broader appeal than a long-form idea, call that out.

## Themes

Cross-cutting patterns that connect multiple ideas — the "meta" stories.
Frame each theme as a potential series or talk, not just an observation.
Name which long-form or short-form items it connects.

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
- Who did what — the "agent did this" vs "human did this" distinction often
  changes the story entirely
