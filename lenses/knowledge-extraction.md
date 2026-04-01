<!-- ABOUTME: Lens for extracting reusable technical learnings, patterns, and engineering process knowledge. -->
<!-- ABOUTME: Produces prescriptive rules and diagnostic playbooks that reduce bus factor and accelerate onboarding. -->

---
name: knowledge-extraction
description: Extract reusable learnings, patterns, and prescriptive rules from session activity
version: 4
---

# Analysis Instructions

Extract actionable knowledge that can be reused across projects and sessions.
The goal is not a session log — it's a reference that helps someone who wasn't
there avoid the same mistakes and apply the same solutions.

On first mention of each project, include a 1-line description so the report
is readable without prior context.

Every item in every section should include a short **Audience** tag (vibes-based,
e.g., "anyone using Compose Navigation", "all Tailwind projects") so a reader
can scan for what's relevant to them without reading full explanations.

Use `##` for sections, `###` for sub-groupings.

## Technical Learnings

Each learning should be a prescriptive rule, not just an observation. Frame as
"do X" or "don't do Y" rather than "we discovered that Z."

For each learning:
- **The rule**: What to do or avoid, stated directly
- **Why**: The failure mode, symptom, or rationale — what goes wrong if ignored
- **Audience**: short, vibes-based — who needs to know this?
- **Scope**: When does this rule apply? When does it NOT apply?
- **Frequency**: how likely is someone to hit this? Use a short tag:
  `common` (most projects will encounter), `occasional` (specific conditions),
  `rare` (edge case worth documenting)

Group by technology domain. Order by frequency (common first).

## Architectural Patterns

### Patterns Worth Reusing
- What the pattern is and when to reach for it
- Why it works (the trade-off it resolves)
- When NOT to use it (boundary conditions)
- **Audience**: who benefits from knowing this?

### Anti-Patterns
- What it looks like (the symptom you'd notice)
- How to detect it — what test, log, or command reveals the problem
- Why it's wrong (the mechanism, not just "it's bad")
- What to do instead
- **Audience**: who needs to watch for this?

## Diagnostic Playbooks

Debugging techniques worth documenting — the *how I figured it out* path, not
just the fix. Only include techniques that transfer across projects.

For each:
- **Symptom**: What you'd observe
- **Diagnostic steps**: The commands, logs, or checks that led to root cause
- **Resolution**: What fixed it
- **Transferable lesson**: When to reach for this diagnostic approach again

Omit this section if no session produced a reusable diagnostic technique.

## Reusable Code & Snippets

Copy-paste ready commands, patterns, or configurations worth saving. Only
include items where the code itself is the value — not snippets that merely
illustrate a learning already covered above.

Omit this section if nothing qualifies.

## Process Insights

Engineering process learnings — what worked well, what should change. Focus on
development practices and team conventions, not AI agent behavior or tooling
workflow (those belong in the workflow-optimization lens).

Omit this section if nothing noteworthy emerged.

## Extraction Hints

When summarizing each session, also capture:
- Debugging stories: not just the fix, but how the root cause was identified —
  what commands, logs, or tools led to the diagnosis
- Edge cases and their solutions
- Configuration insights or environment setup knowledge
- Code patterns that were written from scratch but exist in libraries
- User corrections that suggest a convention or rule the team should adopt
- Framework or library version numbers when a learning is version-sensitive
- Boundary conditions: when does a pattern stop working? At what scale, dataset
  size, or complexity does a technique break down?
- "I wish..." or "this should be..." statements that suggest missing conventions
