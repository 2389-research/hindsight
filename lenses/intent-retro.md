<!-- ABOUTME: Lens for mining sessions for durable user intent — taste rules, constraints, standing preferences. -->
<!-- ABOUTME: Emits fenced draft ledger entries consumable by the intent plugin's /intent-pending triage skill. -->

---
name: intent-retro
description: Mine sessions for durable user intent — taste rules, constraints, standing preferences — and draft ledger entries for the intent plugin
version: 2
---

# Analysis Instructions

Mine the session range for durable user intent — taste rules, constraints,
standing preferences that will prevent future corrections — and emit them as
draft ledger entries in the exact format the intent plugin's `/intent-pending`
triage skill consumes. The output is machine-actionable drafts, not prose.

Verbatim quotes beat paraphrase. The user's exact words are the primary
signal — paraphrasing loses the fidelity that durability judgment depends on.
Preserve leading discourse markers ("ok, ", "so...", "yeah,"), typos, casing,
and punctuation. If a quote must be trimmed, use `[...]` to mark the elision.

## Clustering

Cluster verbatim corrections across sessions before judging any of them.
Group by the underlying rule, not the surface phrasing — "stop hedging" and
"cut the qualifiers" are the same cluster.

A correction that repeats across ≥2 sessions or ≥2 projects sorts first.
Repeat is the strongest durability signal available; a single-session
correction can be a mood, a cross-session repeat almost never is.

## Discard Discipline

Discard ephemeral candidates ruthlessly. Ephemeral = one-off wording tweaks,
typo fixes, bug-specific corrections, or context-bound preferences that
don't generalize. Durable = expresses a rule that would prevent a future
correction in a different session.

Target keep rate is 10–20% of raw corrections. A 10-session range yielding
3 drafts is a good report; the same range yielding 30 drafts is a bad one.
When in doubt, discard.

## Scope Rule

Decide each keeper's scope by where the evidence sits:

- **1 project, evidence local to that project** → target path is
  `<project>/.intent/pending/YYYY-MM-DD-<slug>.md`.
- **Same rule appears in ≥2 projects** → target path is
  `~/.claude/intent/pending/YYYY-MM-DD-<slug>.md` (global).
- **1-project → global override** is permitted only when the draft can meet
  at least one of three universality tests, stated explicitly on the draft:
  1. **Meta test**: the rule governs how ALL future corrections/drafts are
     handled (e.g., "how to route captured corrections" — inherently
     cross-project by shape).
  2. **Methodological test**: the rule is about how the agent reasons, not
     about a domain artifact (e.g., "always merge evidence-mining with
     outside-in readiness" — reasoning axis, cross-project by construction).
  3. **Doctrine-extension test**: the rule cites and explicitly extends an
     existing global doctrine entry along a new axis, with the reviewer's
     cross-reference verified.

  Without at least one of the three, keep it project-scoped and add
  `[watch for repeat]` to the target path.

`<slug>` is a short kebab-case handle for the rule (e.g., `no-hedging`,
`prefer-tabs`, `stop-em-dashes`).

**Category test (apply Draft-3-style):** For every draft, ask "is this a
taste/interaction/aesthetic preference, or an engineering/architectural
constraint or blast-radius rule?" Taste defaults toward global; constraints
default toward project-local. When categorizing pushes against evidence-
weight (e.g., a single-instance constraint would default project-local
even if the universality tests seem to apply), the category rule wins —
mark it project-scoped with `[watch for repeat]`.

## Emitting Keepers

Emit each keeper as a fenced code block. On the line immediately above the
fence, print `**Target path:** <path>` using the scope rule above. If the
draft is a project-scoped keeper held back from global promotion pending
cross-project evidence, append ` [watch for repeat]` to the target-path line.

The fenced block must contain the intent plugin's draft format — the five
base lines plus three lens-required fields, in this exact order:

```
# Proposed intent entry: <short title>
**Proposed entry (Taste|Constraint|Preference):** <the rule, 1-2 sentences>
**Why:** <the user's verbatim words + brief context>
**How to apply:** <when/where the rule kicks in>
**Single-project justification:** <one paragraph — required ONLY when scope is a single-project → global override; state which universality test(s) the draft passes>
**Adjacent doctrine:** <cite existing intent.md entry this rule extends/sharpens, or state "none" — required for every global-scoped draft>
**Durability signal:** <one line: "reinforced across N projects" | "verbatim in-session repeat" | "single-instance meta-rule (governs X)" | "single-instance methodological rule with in-session corroboration" — required>
**Suggested scope:** project <name> | global — <one-line reason>
```

Downstream `/intent-pending` parses the base lines by prefix; the added
fields (Single-project justification, Adjacent doctrine, Durability signal)
travel with the pending .md file so the durability argument doesn't live
only in the retro report.

## Provenance Ledger

Immediately after the fenced block, print one `**Provenance:**` line listing
the session IDs and verbatim quotes that back the draft:

```
**Provenance:** <session-id-shortform> — "<verbatim quote>"; <session-id> — "<verbatim quote>"
```

Session-ID shortform is the first 8 chars of the UUID. Quotes must be
verbatim — preserve leading discourse markers, typos, casing, punctuation.
If a quote is long, keep the load-bearing clause verbatim and trim with
`[...]` only around it, never mid-clause.

## Possibly-Already-Captured Flag

Check three sources for existing captures of each candidate keeper's rule:

1. Every `<project>/.intent/pending/` directory across the projects in the
   range (find with `find … -name '.intent' -type d`).
2. The global standing-taste list in `~/.claude/subfiles/intent.md`.
3. Project-scoped memory files at
   `~/.claude/projects/<encoded-path>/memory/*.md`, especially any
   `feedback_*.md` files — these are the memory-system analog of INTENT.md
   entries and are the highest re-materialization risk when adjacent to
   a keeper draft.

If any of those already captures the rule (or a near-duplicate), tag the
draft with a line immediately after the provenance line:

```
[possibly already captured — check <path>]
```

`<path>` points at the specific file and, when possible, the section that
overlaps. Do not emit this tag speculatively — only when a real overlap
exists.

## Sort Order and Tier Headings

Sort keepers into three tiers and emit each tier under an explicit `###`
heading (or `####` if drafts live under a `### Tier N` heading):

- `### Tier 1 — Cross-project (≥2 projects)`
- `### Tier 2 — Within-project repeat` (same project, ≥2 sessions, OR
  verbatim in-session repeat across ≥2 user turns)
- `### Tier 3 — Single-instance keepers (ordered by leverage)`

Within Tier 3, order by leverage — meta-rules that govern all future drafts
first, then methodological rules that shape agent reasoning, then domain
constraints. This makes the highest-leverage drafts triage-visible first.

## Output Structure

Emit exactly this shape:

    # Intent Retro — <date range>
    *Generated with intent-retro lens v<version>*

    Drafts: N (X Tier 1, Y Tier 2, Z Tier 3)

    ## Drafts

    ### Tier 1 — Cross-project (≥2 projects)

    #### <short title>
    **Target path:** <path>
    ```
    <fenced draft in the extended format>
    ```
    **Provenance:** <session:quote>; …
    [possibly already captured — check <path>]   (only when applicable)

    ### Tier 2 — Within-project repeat
    …

    ### Tier 3 — Single-instance keepers (ordered by leverage)
    …

    ## Actionable notes

    ### Already captured (do not re-draft)
    <existing pending drafts and memory captures that overlap; be complete>

    ### Discarded but worth watching (single-instance; watch for cross-project repeat)
    <one line per discard with reason>

    ## Next: Materialize

    ```bash
    mkdir -p ~/.claude/intent/pending
    ```

    Then: `/intent-pending materialize-from-report <report-path>`
    (or copy-paste the fenced blocks into their target paths).

    <details>
    <summary>Report metadata</summary>

    Sessions scanned, project list, discipline stats, range compliance,
    revision log. Anything the triage reviewer doesn't need mid-triage.

    </details>

Everything above the `<details>` block is triage-actionable content.
Everything inside it is provenance/audit-trail rigor that a triage reviewer
should not have to scroll past.

## Zero-Drafts Fallback

If nothing durable surfaces across the range, emit only the header plus a
single line:

    No durable intent surfaced in this range.

Do not pad. Do not list rejected candidates. Do not explain why nothing
qualified. A short honest report beats a padded one.

## Extraction Hints

When summarizing each session, capture:

- **Verbatim corrections.** Every user correction, quoted exactly.
  **Preserve leading discourse markers** ("ok, ", "so...", "yeah,",
  "hmm..."), typos, casing, and punctuation — no cleanup, no paraphrase.
  Include 1–2 turns of surrounding agent action so the reader can see what
  the correction was reacting to. Corrections include: interrupts;
  "no / not that / wrong / don't / stop doing X"; scope pushback
  ("too much", "simpler"); rejected approaches; taste reactions to
  presented UI or copy.
- **Canonical-verbatim rule.** For each correction, emit exactly one
  canonical verbatim string. If the correction contains multiple sentences
  and only part is load-bearing, elide with `[...]` — do not emit two
  different truncations of the same user turn, which creates summary-
  internal drift and downstream provenance instability.
- **Standing-preference statements** even outside corrections: any turn
  containing "always / never / prefer / from now on / stop doing" applied
  to agent behavior.
- **Ephemeral vs durable tag.** Tag each captured correction with one line
  of evidence. Ephemeral = one-off wording, typo, or bug fix that does not
  generalize. Durable = expresses a rule that would prevent a future
  correction in a different session or project.
- **Repeat flag.** Note whether the agent made a mistake it had already
  been corrected on in this session, or one visibly referenced from prior
  sessions. Repeats are the strongest durability signal — flag them
  explicitly so analysis can sort them first.
- **Project attribution.** Project name is already in session metadata.
  Carry it into each captured correction so cross-project clustering can
  attribute scope correctly.
- **INTENT.md touched.** Record whether any turn read or edited an
  `INTENT.md` file. If yes, capture the diff snippet (or the relevant
  section that was read). This feeds the analysis's
  "possibly-already-captured" flag.
