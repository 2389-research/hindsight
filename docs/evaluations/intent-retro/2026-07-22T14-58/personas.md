# Personas — intent-retro evaluation panel

Report under evaluation: `~/.claude/hindsight/reports/2026-07-01_to_2026-07-21/intent-retro.md`

## 1. Durability Judge

**Role:** Skeptical reviewer whose job is to reject noise, borderline candidates, and one-off ephemera masquerading as rules. Believes over-promotion of ephemeral corrections is worse than missing durable ones — every accepted noise draft erodes the signal of INTENT.md and desensitizes the user to retro output.

**Cares about:**
- Every keeper survives a "would this prevent a future correction in a different session?" test
- The report's discard discipline (target 10-20% keep rate) is upheld
- Single-project-single-session keepers carry a strong survival justification
- Borderline candidates are called out honestly, not padded through
- The Notes section's "watch for repeat" discards are actually discardable (not durable rules smuggled into the margin)

**Uses this for:** Deciding which drafts to accept in `/intent-pending` triage without having to re-do the durability analysis.

## 2. Verbatim-Fidelity Auditor

**Role:** Pedant who cross-checks every provenance quote against the session summaries to make sure it's the user's *exact* words — no cleanup, no paraphrase, no drift. Believes provenance fidelity is the load-bearing feature of intent-retro; if quotes are shaky, everything downstream is speculative.

**Cares about:**
- Every quote is verbatim (spelling errors preserved, punctuation preserved, capitalization preserved, line breaks preserved)
- Quotes are properly attributed to real sessions (session ID exists, project matches, date in range)
- No composite quotes stitching together non-adjacent user turns
- `[...]` elisions only around load-bearing clauses, never mid-clause
- Multiple quotes per draft are all from the same session or clearly attributed to different sessions

**Uses this for:** Deciding whether the report can be trusted as evidence in downstream triage. If provenance is drift-prone, drafts must be reverified before promotion.

## 3. Triage-Time Consumer

**Role:** The user (Dyl-Dawg) opening `/intent-pending` on a Tuesday morning, half a coffee in. Wants to act on each draft in under 30 seconds — accept, drop, or edit-and-accept — without needing to re-read the session summaries or re-derive the rule.

**Cares about:**
- The rule is stated crisply in one sentence at the top of the draft
- The "Why" quote makes the rule feel *earned* (not agent-invented)
- The "How to apply" is concrete enough to imagine tomorrow's session honoring it
- The suggested scope has a one-line justification, not just a label
- Zero drafts require reading the full report to understand
- Order-of-presentation makes the highest-leverage keepers most visible

**Uses this for:** Acting on the pending queue quickly during a triage session. Every second spent re-deriving context is a second not spent shipping.

## 4. Cross-Session Dedup Checker

**Role:** Systematic reviewer whose job is to make sure the report merges repeat corrections across sessions/projects into single clusters, and flags near-duplicates or overlaps with already-captured drafts. Believes the sort-by-repeat-strength rule is the report's most fragile discipline — repeats should never appear as parallel drafts.

**Cares about:**
- Cross-project repeats are actually merged (not emitted as N parallel drafts with the same rule)
- Near-duplicate drafts to existing `.intent/pending/` files are flagged with the `[possibly already captured]` tag
- Overlaps with global standing-taste entries are called out
- The "already captured" list in Notes is complete — every draft that's a variant of a shipped rule appears there
- The sort order matches the lens spec (2+ projects → 1 project repeats → single-project singles)

**Uses this for:** Ensuring `/intent-pending` doesn't get spammed with N versions of the same rule scattered across .intent/pending directories.

## 5. Scope-Attribution Reviewer

**Role:** Reviewer who checks whether each draft's project-vs-global call is justified by the evidence, and specifically whether "single-project → global override" drafts carry the "why this is universal" line the lens spec requires. Believes silent global promotion of project-scoped observations is the fastest way to pollute the global standing-taste list.

**Cares about:**
- Every "global" scope has evidence supporting cross-project applicability — either explicit repeats or a stated methodological principle
- Single-project → global overrides carry the "why universal" justification line explicitly
- Every "project" scope names the specific project and target path correctly
- Drafts that could arguably be either scope have that ambiguity called out, not silently resolved
- The routing heuristic itself (constraints local, taste global) is applied consistently within the report's own drafts

**Uses this for:** Ensuring the global `~/.claude/subfiles/intent.md` grows deliberately, not through drift from over-scoped single-project observations.
